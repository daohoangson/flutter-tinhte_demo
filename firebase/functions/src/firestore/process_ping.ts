import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';
import * as striptags from 'striptags';

import {
  Config,
  firestoreCollectionSubscriptions,
  firestoreCollectionRegistrationTokens,
  firestoreCollectionPings,
  firestoreFieldProcessStartDate,
  firestoreFieldSendDate,
  firestoreFieldSentPayload,
  firestoreCollectionInvalids,
  firestoreFieldInvalidDate,
  firestoreFieldInvalidError,
  firestoreFieldInvalidRegistrationToken,
} from '../common/config';

export default (_: Config) => functions.firestore
  .document(`${firestoreCollectionPings}/{pingID}`)
  .onCreate(async (snap) => {
    const ping = snap.data();
    await snap.ref.update({ [firestoreFieldProcessStartDate]: admin.firestore.FieldValue.serverTimestamp() });

    const { id: pingId } = snap;
    const { data: pingData } = ping as any;
    if (!pingData) {
      console.error(`[${pingId}] pingData=${pingData}`);
      return;
    }

    const { object_data: objectData, topic } = pingData;
    if (!objectData || !topic) {
      console.error(`[${pingId}] objectData=${objectData} topic=${topic}`);
      return;
    }

    const [payload, registrationTokens] = await Promise.all([
      _buildPayload(objectData),
      _getRegistrationTokens(topic),
    ]);
    if (!registrationTokens) {
      console.warn(`[${pingId}] topic=${topic} registrationTokens=${registrationTokens}`);
      return;
    }

    const [batchResponse] = await Promise.all([
      admin.messaging().sendMulticast({
        tokens: registrationTokens,
        ...payload,
      }),
      snap.ref.update({
        [firestoreFieldSendDate]: admin.firestore.FieldValue.serverTimestamp(),
        [firestoreFieldSentPayload]: payload,
      }),
    ]);

    if (batchResponse.failureCount === 0) {
      console.log(`[${pingId}] topic=${topic} successCount=${batchResponse.successCount}`);
      return;
    }

    const invalidPromises: Promise<any>[] = [];
    const invalidIds: string[] = [];
    batchResponse.responses.forEach((response, i) => {
      const registrationToken = registrationTokens[i];

      const { error } = response;
      if (!error) return;
      const { code, message } = error;

      // https://firebase.google.com/docs/cloud-messaging/send-message#admin
      switch (code) {
        case 'messaging/authentication-error':
        case 'messaging/invalid-package-name':
        case 'messaging/invalid-recipient':
        case 'messaging/invalid-registration-token':
        case 'messaging/mismatched-credential':
        case 'messaging/registration-token-not-registered':
          invalidPromises.push(admin.firestore()
            .collection(firestoreCollectionInvalids).add({
              [firestoreFieldInvalidDate]: admin.firestore.FieldValue.serverTimestamp(),
              [firestoreFieldInvalidError]: { code, message },
              [firestoreFieldInvalidRegistrationToken]: registrationToken,
            }).then(
              (ref) => invalidIds.push(ref.id),
              (reason) => console.error(`${registrationToken} -> ${message} -> ${reason}`),
            )
          );
          break;
        default:
          console.error(`${registrationToken} -> ${message}`);
      }
    });

    if (invalidPromises.length > 0) {
      await Promise.all(invalidPromises);
      console.log(`[${pingId}] topic=${topic} invalidIds=${invalidIds}`);
    }
  });

const _buildPayload = (objectData: any): {
  data?: { [key: string]: string },
  notification?: admin.messaging.Notification,
  android?: admin.messaging.AndroidConfig,
  apns?: admin.messaging.ApnsConfig,
} => {
  const data: { [key: string]: string } = {};
  const notification: admin.messaging.Notification = {};
  let badge: number | undefined;
  let tag: string | undefined;

  const {
    // alert
    notification_id: notificationId,
    notification_html: notificationHtml,

    // conversation
    creator_username: creatorUsername,
    message: convoMessage,

    // badges
    user_unread_conversation_count: convoCount,
    user_unread_notification_count: notificationCount,
  } = objectData;

  if (notificationId && notificationId > 0 && notificationHtml) {
    data['notification_id'] = `${notificationId}`;

    notification.body = striptags(notificationHtml).trim().replace(/\s{2,}/g, ' ');
    tag = `notificationId=${notificationId}`
  }

  if (Object.keys(notification).length === 0 && creatorUsername && convoMessage) {
    const {
      conversation_id: convoId,
      message: convoMessageBody,
      message_id: convoMessageId,
      title: convoTitle,
    } = convoMessage;
    if (convoId && convoMessageBody && convoMessageId && convoTitle) {
      notification.title = convoTitle;
      notification.body = `${creatorUsername}: ${convoMessageBody}`;
      tag = `conversationId=${convoId} messageId=${convoMessageId}`;
    }
  }

  const hasNotification = Object.keys(notification).length > 0;
  if (hasNotification) {
    badge = 0;
    if (convoCount) badge += convoCount;
    if (notificationCount) badge += notificationCount;
  }

  for (const key in objectData) {
    switch (key) {
      case 'notification_id':
      case 'notification_html':
        // already processed above, ignore these here
        break;
      default:
        _prepareDataValue(data, key, objectData[key]);
    }
  }

  return {
    data,
    notification: hasNotification ? notification : undefined,
    android: hasNotification ? {
      notification: {
        clickAction: 'FLUTTER_NOTIFICATION_CLICK',
        tag,
      },
    } : undefined,
    apns: hasNotification ? {
      payload: {
        aps: {
          badge,
          contentAvailable: !hasNotification,
        },
      },
    } : undefined,
  };
}

const _getRegistrationTokens = async (topic: string): Promise<string[]> => {
  const snapshot = await admin.firestore()
    .collection(firestoreCollectionSubscriptions).doc(topic)
    .collection(firestoreCollectionRegistrationTokens).get();
  return snapshot.docs.map((registrationToken) => registrationToken.id);
}

const _prepareDataValue = (target: any, key: string, value: any): void => {
  // invalid data key
  if (key === 'from' || key === 'gcm' || key.startsWith('google')) {
    return;
  }

  if (typeof value === 'object') {
    for (const k in value) {
      _prepareDataValue(target, `${key}.${k}`, value[k]);
    }
  } else {
    target[key] = `${value}`;
  }
}

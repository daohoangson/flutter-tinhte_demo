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
  firestoreFieldSentOptions,
} from '../common/config';

export default (_: Config) => functions.firestore
  .document(`${firestoreCollectionPings}/{pingID}`)
  .onCreate(async (snap) => {
    const ping = snap.data();
    await snap.ref.update({ [firestoreFieldProcessStartDate]: admin.firestore.FieldValue.serverTimestamp() });

    const { id: pingId } = snap;
    const { data: pingData } = ping as any;
    if (!pingData) {
      console.error(`[${pingId}] ping.data=${pingData}`);
      return;
    }

    const { object_data: objectData, topic } = pingData;
    if (!objectData || !topic) {
      console.error(`[${pingId}] objectData=${objectData} topic=${topic}`);
      return;
    }

    const [{ data, notification, contentAvailable }, registrationTokens] = await Promise.all([
      _buildMessage(objectData),
      _getRegistrationTokens(topic),
    ]);
    if (!registrationTokens) {
      console.warn(`[${pingId}] topic=${topic} registrationTokens=${registrationTokens}`);
      return;
    }

    const payload: admin.messaging.MessagingPayload = { data, notification };
    const options: admin.messaging.MessagingOptions = { contentAvailable };

    const [sendResult] = await Promise.all([
      admin.messaging().sendToDevice(registrationTokens, payload, options),
      snap.ref.update({
        [firestoreFieldSendDate]: admin.firestore.FieldValue.serverTimestamp(),
        [firestoreFieldSentPayload]: payload,
        [firestoreFieldSentOptions]: options,
      }),
    ]);

    if (sendResult.failureCount === 0) {
      console.log(`[${pingId}] topic=${topic} successCount=${sendResult.successCount}`)
      return;
    }

    // TODO: handle token errors
    console.error(`[${pingId}] sendResults=${sendResult.results}`);
  });

const _buildMessage = (objectData: any): {
  data: any,
  notification: any,
  contentAvailable: boolean,
} => {
  const data: any = {}, notification: any = {};
  let hasData = false;
  let hasNotification = false;
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
    hasData = true;
    data['notification_id'] = `${notificationId}`;

    hasNotification = true;
    notification['body'] = striptags(notificationHtml);
    notification['tag'] = `notificationId=${notificationId}`
  }

  if (!hasNotification && creatorUsername && convoMessage) {
    const {
      conversation_id: convoId,
      message: convoMessageBody,
      message_id: convoMessageId,
      title: convoTitle,
    } = convoMessage;
    if (convoId && convoMessageBody && convoMessageId && convoTitle) {
      hasNotification = true;
      notification['title'] = convoTitle;
      notification['body'] = `${creatorUsername}: ${convoMessageBody}`;
      notification['tag'] = `conversationId=${convoId} messageId=${convoMessageId}`;
    }
  }

  if (hasNotification) {
    let badge = 0;
    if (convoCount) badge += convoCount;
    if (notificationCount) badge += notificationCount;
    notification['badge'] = `${badge}`;

    notification['clickAction'] = 'FLUTTER_NOTIFICATION_CLICK';
  }

  for (const key in objectData) {
    switch (key) {
      case 'notification_id':
      case 'notification_html':
        // already processed above, ignore these here
        break;
      default:
        if (_prepareDataValue(data, key, objectData[key])) {
          hasData = true;
        }
    }
  }

  return {
    data: hasData ? data : undefined,
    notification: hasNotification ? notification : undefined,
    contentAvailable: !hasNotification,
  };
}

const _getRegistrationTokens = async (topic: string): Promise<string[]> => {
  const snapshot = await admin.firestore()
    .collection(firestoreCollectionSubscriptions).doc(topic)
    .collection(firestoreCollectionRegistrationTokens).get();
  return snapshot.docs.map((doc) => doc.id);
}

const _prepareDataValue = (target: any, key: string, value: any): boolean => {
  let hasData = false;

  // invalid data key
  if (key === 'from' || key === 'gcm' || key.startsWith('google')) {
    return hasData;
  }

  if (typeof value === 'object') {
    for (const k in value) {
      if (_prepareDataValue(target, `${key}.${k}`, value[k])) {
        hasData = true;
      }
    }
  } else {
    target[key] = `${value}`;
    hasData = true;
  }

  return hasData;
}
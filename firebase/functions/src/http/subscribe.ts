import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';

import {
  Config,
  firestoreCollectionSubscriptions,
  firestoreCollectionRegistrationTokens,
  firestoreFieldSubscribeDate,
  extraParamsParamKey,
  registrationTokenParamKey,
} from '../common/config';

export default (config: Config) => functions.https.onRequest(async (req, resp) => {
  const {
    body: {
      [extraParamsParamKey]: extraParams,
      'hub.topic': hubTopic,
      [registrationTokenParamKey]: registrationToken,
    },
  } = req;

  if (!hubTopic || !registrationToken) { resp.sendStatus(400); return; }

  const statusCode = await Promise.all([
    fetch(
      config.getHubUrl(),
      {
        method: 'POST',
        body: new URLSearchParams({
          ...extraParams,
          'hub.callback': config.getWebsubUrl(),
          'hub.topic': hubTopic,
          'hub.mode': 'subscribe',
        }),
      }
    ),
    admin.firestore()
      .collection(firestoreCollectionSubscriptions).doc(hubTopic)
      .collection(firestoreCollectionRegistrationTokens).doc(registrationToken).set({
        [firestoreFieldSubscribeDate]: admin.firestore.FieldValue.serverTimestamp(),
      }),
    admin.firestore()
      .collection(firestoreCollectionRegistrationTokens).doc(registrationToken)
      .collection(firestoreCollectionSubscriptions).doc(hubTopic)
      .set({
        [firestoreFieldSubscribeDate]: admin.firestore.FieldValue.serverTimestamp(),
      }),
  ]).then<number, number>(
    ([hubResp]) => {
      const hubRespMessage = `hubTopic=${hubTopic} registrationToken=${registrationToken} hubResp.statusCode=${hubResp.status}`;
      if (hubResp.status !== 202) {
        console.error(hubRespMessage);
        return hubResp.status;
      } else {
        console.log(hubRespMessage);
      }

      return 202;
    },
    (reason) => {
      console.error(reason);
      return 500;
    },
  );

  resp.sendStatus(statusCode);
});

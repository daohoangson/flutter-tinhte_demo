import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';

import {
  Config,
  firestoreCollectionPings,
  firestoreFieldPingData,
  firestoreFieldPingDate,
} from '../common/config';

export default (_: Config) => functions.https.onRequest(async (req, resp) => {
  const {
    body,
    query: {
      'hub.challenge': challenge,
    },
  } = req;

  if (challenge) return resp.send(challenge);

  if (!Array.isArray(body)) return resp.sendStatus(400);
  if (body.length === 0) return resp.sendStatus(200);

  const pingIds: string[] = [];
  await Promise.all(body.map((ping) => admin.firestore()
    .collection(firestoreCollectionPings).add({
      [firestoreFieldPingData]: ping,
      [firestoreFieldPingDate]: admin.firestore.FieldValue.serverTimestamp(),
    }).then(
      (ref) => pingIds.push(ref.id),
      (reason) => console.error(`${ping} -> ${reason}`),
    )));

  if (pingIds.length > 0) {
    console.log(`pingIds=${pingIds}`);
    return resp.sendStatus(202);
  } else {
    return resp.sendStatus(500);
  }
});

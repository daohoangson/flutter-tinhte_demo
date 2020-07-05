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

  if (challenge) { resp.send(challenge); return; }

  if (!Array.isArray(body)) { resp.sendStatus(400); return; }
  if (body.length === 0) { resp.sendStatus(200); return; }

  const pingIds: string[] = [];
  await Promise.all(body.map((ping) => admin.firestore()
    .collection(firestoreCollectionPings).add({
      [firestoreFieldPingData]: ping,
      [firestoreFieldPingDate]: admin.firestore.FieldValue.serverTimestamp(),
    }).then(
      (ref) => pingIds.push(ref.id),
      (reason) => console.error(`${ping} -> ${reason}`),
    )));

  if (pingIds.length === 0) { resp.sendStatus(500); return; }

  console.log(`pingIds=${pingIds}`);
  resp.sendStatus(202);
});

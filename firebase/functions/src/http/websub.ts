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

  if (!Array.isArray(body)) {
    console.error(`body !isArray`);
    return resp.sendStatus(400);
  }

  let fulfilled = 0;
  let rejected = 0;
  await Promise.all(body.map((ping) => admin.firestore()
    .collection(firestoreCollectionPings).add({
      [firestoreFieldPingData]: ping,
      [firestoreFieldPingDate]: admin.firestore.FieldValue.serverTimestamp(),
    }).then(
      () => fulfilled++,
      (reason) => { rejected++; console.error(reason); },
    )));

  console.log(`fulfilled=${fulfilled}, rejected=${rejected}`);

  return resp.sendStatus(202);
});

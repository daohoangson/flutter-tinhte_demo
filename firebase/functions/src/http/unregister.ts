import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';

import {
  Config,
  firestoreCollectionSubscriptions,
  firestoreCollectionRegistrationTokens,
  registrationTokenParamKey,
} from '../common/config';

export default (_: Config) => functions.https.onRequest(async (req, resp) => {
  const {
    body: {
      [registrationTokenParamKey]: registrationToken,
    },
  } = req;

  if (!registrationToken) return resp.sendStatus(400);

  const snapshot = await admin.firestore()
    .collection(firestoreCollectionRegistrationTokens).doc(registrationToken)
    .collection(firestoreCollectionSubscriptions).get();

  let fulfilled = 0;
  let rejected = 0;
  await Promise.all(snapshot.docs.map((subscription) => admin.firestore()
    .collection(firestoreCollectionSubscriptions).doc(subscription.id)
    .collection(firestoreCollectionRegistrationTokens).doc(registrationToken)
    .delete()
    .then(
      () => fulfilled++,
      (reason) => { rejected++; console.error(reason); }
    )));

  console.log(`fulfilled=${fulfilled}, rejected=${rejected}`);

  return resp.sendStatus(202);
});

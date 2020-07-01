import * as admin from 'firebase-admin';

import {
  firestoreCollectionSubscriptions,
  firestoreCollectionRegistrationTokens,
} from './config';

export default async (registrationToken: string): Promise<boolean> => {
  const snapshot = await admin.firestore()
    .collection(firestoreCollectionRegistrationTokens).doc(registrationToken)
    .collection(firestoreCollectionSubscriptions).get();

  if (snapshot.empty) {
    console.warn(`[${registrationToken}] snapshot.empty`);
    return false;
  }

  const hubTopics: string[] = [];
  await Promise.all(snapshot.docs.map((subscription) => admin.firestore()
    .collection(firestoreCollectionSubscriptions).doc(subscription.id)
    .collection(firestoreCollectionRegistrationTokens).doc(registrationToken)
    .delete()
    .then(
      () => hubTopics.push(subscription.id),
      (reason) => console.error(`[${registrationToken}] ${subscription.id} -> ${reason}`)
    )));

  // TODO: unsubscribe from XF

  if (hubTopics.length > 0) {
    console.log(`[${registrationToken}] hubTopics=${hubTopics}`);
    return true;
  } else {
    return false;
  }
};
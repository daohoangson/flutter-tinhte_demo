import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';

import {
  Config,
  firestoreCollectionInvalids,
  firestoreFieldProcessStartDate,
  firestoreFieldInvalidRegistrationToken,
} from '../common/config';
import unsubscribe from '../common/unsubscribe';

export default (_: Config) => functions.firestore
  .document(`${firestoreCollectionInvalids}/{invalidID}`)
  .onCreate(async (snap) => {
    const invalid = snap.data();
    await snap.ref.update({ [firestoreFieldProcessStartDate]: admin.firestore.FieldValue.serverTimestamp() });

    const { id: invalidId } = snap;
    const { [firestoreFieldInvalidRegistrationToken]: registrationToken } = invalid as any;
    if (!registrationToken) {
      console.error(`[${invalidId}] registrationToken=${registrationToken}`);
      return;
    }

    await unsubscribe(registrationToken);
  });

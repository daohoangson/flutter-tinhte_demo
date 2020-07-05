import * as functions from 'firebase-functions';

import {
  Config,
  registrationTokenParamKey,
} from '../common/config';
import unsubscribe from '../common/unsubscribe';

export default (_: Config) => functions.https.onRequest(async (req, resp) => {
  const {
    body: {
      [registrationTokenParamKey]: registrationToken,
    },
  } = req;

  if (!registrationToken) { resp.sendStatus(400); return; }

  if (!await unsubscribe(registrationToken)) { resp.sendStatus(500); return; }

  resp.sendStatus(202);
});

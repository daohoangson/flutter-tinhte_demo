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

  if (!registrationToken) return resp.sendStatus(400);

  if (await unsubscribe(registrationToken)) {
    return resp.sendStatus(202);
  } else {
    return resp.sendStatus(500);
  }
});

import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';

import { Config } from './common/config';
import firestoreProcessInvalid from './firestore/process_invalid';
import firestoreProcessPing from './firestore/process_ping';
import httpSubscribe from './http/subscribe';
import httpUnregister from './http/unregister';
import httpWebsub from './http/websub';

class _Config implements Config {
  _config: {
    hub: string,
    url: string,
  };

  constructor() {
    admin.initializeApp();

    // firebase functions:config:set websub.foo=bar
    this._config = functions.config().websub || {
      hub: process.env.WEBSUB_HUB || 'https://domain.com/xenforo/api/index.php?subscriptions',
      url: process.env.WEBSUB_URL || 'https://region-project.cloudfunctions.net/websub',
    };
  }

  getHubUrl = () => this._config.hub;

  getWebsubUrl = () => this._config.url;
}

const config = new _Config();

export const processInvalid = firestoreProcessInvalid(config);
export const processPing = firestoreProcessPing(config);
export const subscribe = httpSubscribe(config);
export const unregister = httpUnregister(config);
export const websub = httpWebsub(config);

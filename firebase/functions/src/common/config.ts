export interface Config {
  getHubUrl(): string;
  getWebsubUrl(): string;
}

export const firestoreCollectionSubscriptions = 'subscriptions';
export const firestoreCollectionRegistrationTokens = 'registration_tokens';
export const firestoreFieldSubscribeDate = 'subscribe_date';

export const firestoreCollectionPings = 'pings';
export const firestoreFieldPingData = 'data';
export const firestoreFieldPingDate = 'ping_date';
export const firestoreFieldProcessStartDate = 'process_start_date';
export const firestoreFieldSendDate = 'send_date';
export const firestoreFieldSentPayload = 'payload';
export const firestoreFieldSentOptions = 'options';

export const extraParamsParamKey = 'extra_params';
export const registrationTokenParamKey = 'registration_token';

part of '../api.dart';

const _kHeaderTfaProviders = 'x-api-tfa-providers';

Future<LoginResult> _postOauthToken(
  Api api,
  ObtainMethod obtainMethod,
  String path,
  Map<String, String> bodyFields,
) async {
  try {
    final json = await api.postJson(path, bodyFields: bodyFields);
    if (json is! Map<String, dynamic>) {
      return Future.error(ApiErrorUnexpectedResponse(json));
    }

    if (!json.containsKey('access_token')) {
      return Future.error(ApiErrorUnexpectedResponse(json));
    }

    return LoginResult.token(OauthToken.fromJson(json, obtainMethod));
  } on ApiError {
    final headers = api.latestResponse?.headers ?? const {};
    final providersString = headers[_kHeaderTfaProviders];
    if (providersString != null) {
      final providers = providersString
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty);
      if (providers.isNotEmpty) {
        return LoginResult.tfa(
            LoginTfa(bodyFields, obtainMethod, path, providers));
      }
    }

    rethrow;
  }
}

Future<LoginResult> login(Api api, String username, String password) =>
    _postOauthToken(api, ObtainMethod.usernamePassword, 'oauth/token', {
      "grant_type": "password",
      "client_id": api.clientId,
      "client_secret": api.clientSecret,
      "username": username,
      "password": password,
    });

Future<LoginResult> loginAssociate(Api api, LoginAssociatable a, String pass) =>
    _postOauthToken(
        api,
        a.obtainMethod,
        'oauth/token/associate',
        Map.from(a.bodyFields)
          ..addAll({
            "client_id": api.clientId,
            "client_secret": api.clientSecret,
            "password": pass,
          }));

Future<LoginResult> loginExternal(
  Api api,
  ObtainMethod obtainMethod,
  Map<String, String> bodyFields,
) async {
  final omId = obtainMethod.toString().split('.').last;
  final json = await api.postJson('oauth/token/$omId', bodyFields: bodyFields);

  if (json is! Map<String, dynamic>) {
    return Future.error(ApiErrorUnexpectedResponse(json));
  }

  if (json.containsKey('message')) {
    if (json.containsKey('user_data')) {
      final Map<String, dynamic> userData = json['user_data'];
      if (userData.containsKey('associatable')) {
        final associatable = LoginAssociatable.fromJson(userData, obtainMethod);
        if (associatable != null) return LoginResult.associatable(associatable);
      }

      final token = await _tryAutoRegister(api, obtainMethod, userData);
      if (token != null) return LoginResult.token(token);
    }

    return Future.error(ApiErrorSingle(json['message']));
  }

  if (!json.containsKey('access_token')) {
    return Future.error(ApiErrorUnexpectedResponse(json));
  }

  return LoginResult.token(OauthToken.fromJson(json, obtainMethod));
}

Future<LoginResult> loginTfa(
  Api api,
  LoginTfa tfa,
  String provider, {
  bool? trigger,
  String? code,
}) async {
  try {
    return await _postOauthToken(
        api,
        tfa.obtainMethod,
        tfa.path,
        Map.from(tfa.bodyFields)
          ..addAll({
            'tfa_provider': provider,
            if (trigger == true) 'tfa_trigger': '1',
            if (code != null) 'code': code,
          }));
  } on ApiErrorUnexpectedResponse {
    if (trigger == true && api.latestResponse?.statusCode == 200) {
      return LoginResult.tfa(tfa.copyWith(triggeredProvider: provider));
    }

    rethrow;
  }
}

Future<OauthToken?> _tryAutoRegister(
  Api api,
  ObtainMethod obtainMethod,
  Map<String, dynamic> userData,
) async {
  if (!userData.containsKey('extra_data') ||
      !userData.containsKey('extra_timestamp') ||
      !userData.containsKey('user_email')) {
    return null;
  }

  final bodyFields = {
    'client_id': api.clientId,
    'client_secret': api.clientSecret,
  };
  for (final e in userData.entries) {
    try {
      bodyFields[e.key] = e.value.toString();
    } catch (e) {
      print(e);
    }
  }

  if (!bodyFields.containsKey('username')) {
    final email = userData['user_email'] as String;
    final emailName = email.replaceAll(RegExp(r'@.+$'), '');
    final timestamp = (DateTime.now().millisecondsSinceEpoch / 1000).floor();
    bodyFields['username'] = "${emailName}_$timestamp";
  }

  final json = await api.postJson('users', bodyFields: bodyFields);
  if (json is! Map) return null;

  if (!json.containsKey('token')) return null;
  return OauthToken.fromJson(json['token'], obtainMethod);
}

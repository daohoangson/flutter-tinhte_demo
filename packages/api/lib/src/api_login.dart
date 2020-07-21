part of '../api.dart';

const _kHeaderTfaProviders = 'x-api-tfa-providers';

Future<LoginResult> _postOauthToken(
  Api api,
  ObtainMethod om,
  String path,
  Map<String, String> bodyFields,
) async {
  try {
    final json = await api.postJson(path, bodyFields: bodyFields);
    if (json is! Map) return Future.error(ApiErrorUnexpectedResponse(json));

    final map = json as Map;
    if (!map.containsKey('access_token'))
      return Future.error(ApiErrorUnexpectedResponse(json));

    return LoginResult.token(OauthToken.fromJson(map)..obtainMethod = om);
  } on ApiError catch (e) {
    final headers = api.latestResponse?.headers;
    if (headers?.containsKey(_kHeaderTfaProviders) == true) {
      final providers = headers['x-api-tfa-providers']
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty);
      if (providers.isNotEmpty)
        return LoginResult.tfa(LoginTfa._(bodyFields, om, path, providers));
    }
    throw e;
  }
}

Future<LoginResult> login(Api api, String username, String password) =>
    _postOauthToken(api, ObtainMethod.UsernamePassword, 'oauth/token', {
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
        Map.from(a._bodyFields)
          ..addAll({
            "client_id": api.clientId,
            "client_secret": api.clientSecret,
            "password": pass,
          }));

Future<LoginResult> loginExternal(
  Api api,
  ObtainMethod om,
  Map<String, String> bodyFields,
) async {
  final omId = om.toString().replaceFirst('ObtainMethod.', '').toLowerCase();
  final json = await api.postJson('oauth/token/$omId', bodyFields: bodyFields);

  if (json is! Map) return Future.error(ApiErrorUnexpectedResponse(json));
  final map = json as Map;

  if (map.containsKey('message')) {
    if (map.containsKey('user_data')) {
      final Map<String, dynamic> userData = map['user_data'];
      if (userData.containsKey('associatable')) {
        final associatable = LoginAssociatable.fromJson(om, userData);
        if (associatable != null) return LoginResult.associatable(associatable);
      }

      final token = await _tryAutoRegister(api, om, userData);
      if (token != null) return LoginResult.token(token);
    }

    return Future.error(ApiErrorSingle(map['message']));
  }

  if (!map.containsKey('access_token'))
    return Future.error(ApiErrorUnexpectedResponse(map));

  return LoginResult.token(OauthToken.fromJson(map)..obtainMethod = om);
}

Future<LoginResult> loginTfa(
  Api api,
  LoginTfa tfa,
  String provider, {
  bool trigger,
  String code,
}) async {
  try {
    return await _postOauthToken(
        api,
        tfa.obtainMethod,
        tfa.path,
        Map.from(tfa._bodyFields)
          ..addAll({
            'tfa_provider': provider,
            'tfa_trigger': trigger == true ? '1' : '',
            'code': code != null ? code : '',
          }));
  } on ApiErrorUnexpectedResponse catch (e) {
    if (trigger == true && api.latestResponse?.statusCode == 200) {
      return LoginResult.tfa(tfa.triggered(provider));
    }

    throw e;
  }
}

Future<OauthToken> _tryAutoRegister(
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

  final map = json as Map;
  if (!map.containsKey('token')) return null;

  return OauthToken.fromJson(map['token'])..obtainMethod = obtainMethod;
}

class LoginAssociatable {
  final Map<String, String> _bodyFields;
  final ObtainMethod obtainMethod;
  final String username;

  LoginAssociatable._(
    this._bodyFields,
    this.obtainMethod,
    this.username,
  );

  factory LoginAssociatable.fromJson(
    ObtainMethod obtainMethod,
    Map<String, dynamic> userData,
  ) {
    if (!userData.containsKey('associatable') ||
        !userData.containsKey('extra_data') ||
        !userData.containsKey('extra_timestamp')) return null;

    final entries = (userData['associatable'] as Map<String, dynamic>).entries;
    for (final entry in entries) {
      final Map<String, dynamic> value = entry.value;
      if (!value.containsKey('username')) continue;

      return LoginAssociatable._(
        Map.unmodifiable({
          'user_id': entry.key,
          'extra_data': userData['extra_data'],
          'extra_timestamp': userData['extra_timestamp'].toString(),
        }),
        obtainMethod,
        value['username'],
      );
    }

    return null;
  }
}

class LoginTfa {
  final Map<String, String> _bodyFields;
  final ObtainMethod obtainMethod;
  final String path;
  final Iterable<String> providers;
  final String triggeredProvider;

  LoginTfa._(
    this._bodyFields,
    this.obtainMethod,
    this.path,
    this.providers, {
    this.triggeredProvider,
  });

  LoginTfa triggered(String provider) => LoginTfa._(
        _bodyFields,
        obtainMethod,
        path,
        providers,
        triggeredProvider: provider,
      );
}

class LoginResult {
  final LoginAssociatable associatable;
  final OauthToken token;
  final LoginTfa tfa;

  LoginResult.associatable(this.associatable)
      : tfa = null,
        token = null;

  LoginResult.tfa(this.tfa)
      : associatable = null,
        token = null;

  LoginResult.token(this.token)
      : associatable = null,
        tfa = null;
}

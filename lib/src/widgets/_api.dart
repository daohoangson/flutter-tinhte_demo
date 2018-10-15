import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tinhte_api/api.dart';
import 'package:tinhte_api/batch_controller.dart';
import 'package:tinhte_api/oauth_token.dart';

import '../screens/login.dart';
import '../constants.dart';

typedef void ApiAction(ApiData apiData);

void prepareForApiAction(BuildContext context, ApiAction onReady,
    {ApiAction onError}) async {
  final apiData = ApiInheritedWidget.of(context);
  final token = await apiData.tokenAsync;
  if (token == null) {
    final loggedIn = await pushLoginScreen(context);
    if (loggedIn != true) {
      if (onError != null) onError(apiData);
      return;
    }
  }

  try {
    onReady(apiData);
  } on ApiError {
    return;
  }
}

class ApiInheritedWidget extends StatefulWidget {
  final Api api;
  final Widget child;

  ApiInheritedWidget({
    Key key,
    @required this.api,
    @required this.child,
  }) : super(key: key);

  @override
  State<ApiInheritedWidget> createState() => ApiData();

  static ApiData of(BuildContext context) =>
      (context.inheritFromWidgetOfExactType(_Inherited) as _Inherited).data;
}

class ApiData extends State<ApiInheritedWidget> {
  ApiWrapper get api => ApiWrapper(this);

  OauthToken _token;

  OauthToken get token => _token;

  Future<OauthToken> get tokenAsync async {
    if (_token == null) return Future.value(null);
    if (_token.expiresAt.isAfter(DateTime.now())) return _token;

    // TODO: handle concurrent request for token better
    // with the current implementation, tokenAsync caller will get `null`
    // while it's being refreshed...
    final refreshToken = _token.refreshToken;
    _token = null;

    try {
      debugPrint('Token has been expired, refreshing now...');
      final newToken = await widget.api.refreshToken(refreshToken);
      _setToken(newToken);

      return newToken;
    } on ApiError {
      return Future.value(null);
    }
  }

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((SharedPreferences prefs) {
      final clientId = prefs.getString(kPrefKeyTokenClientId);
      if (clientId != widget.api.clientId) return;

      final accessToken = prefs.getString(kPrefKeyTokenAccessToken);
      final expiresAtMillisecondsSinceEpoch =
          prefs.getInt(kPrefKeyTokenExpiresAtMillisecondsSinceEpoch) ?? 0;
      final refreshToken = prefs.getString(kPrefKeyTokenRefreshToken);
      final scope = prefs.getString(kPrefKeyTokenScope);
      final userId = prefs.getInt(kPrefKeyTokenUserId);
      if (accessToken?.isNotEmpty != true ||
          expiresAtMillisecondsSinceEpoch < 1 ||
          refreshToken?.isNotEmpty != true) return;

      final expiresIn = ((expiresAtMillisecondsSinceEpoch -
                  DateTime.now().millisecondsSinceEpoch) /
              1000)
          .floor();
      final token =
          OauthToken(accessToken, expiresIn, refreshToken, scope, userId);
      debugPrint("Restored token $accessToken, expires in $expiresIn");
      setState(() => _token = token);
    });
  }

  @override
  Widget build(BuildContext context) =>
      _Inherited(child: widget.child, data: this);

  void _setToken(OauthToken value) {
    SharedPreferences.getInstance().then((SharedPreferences prefs) {
      prefs.setString(kPrefKeyTokenAccessToken, value?.accessToken);
      prefs.setString(kPrefKeyTokenClientId, widget.api.clientId);
      prefs.setInt(kPrefKeyTokenExpiresAtMillisecondsSinceEpoch,
          value?.expiresAt?.millisecondsSinceEpoch);
      prefs.setString(kPrefKeyTokenRefreshToken, value?.refreshToken);
      prefs.setString(kPrefKeyTokenScope, value?.scope);
      prefs.setInt(kPrefKeyTokenUserId, value?.userId);
      debugPrint("Saved token ${value?.accessToken}," +
          " expires at ${value?.expiresAt}");
    });

    setState(() => _token = value);
  }
}

class ApiWrapper {
  final ApiData apiData;
  final Api api;

  ApiWrapper(this.apiData) : api = apiData.widget.api;

  Future<dynamic> deleteJson(path) => api.deleteJson(_appendOauthToken(path));

  Future<dynamic> getJson(path) => api.getJson(_appendOauthToken(path));

  Future<OauthToken> login(String username, String password) =>
      api.login(username, password).then((token) {
        apiData._setToken(token);
        return token;
      });

  logout() => apiData._setToken(null);

  BatchController newBatch() => api.newBatch(path: _appendOauthToken('batch'));

  Future<dynamic> postJson(path, {Map<String, String> bodyFields}) =>
      api.postJson(_appendOauthToken(path), bodyFields: bodyFields);

  String _appendOauthToken(String path) {
    final token = apiData._token;
    final accessToken = token?.accessToken ?? api.buildOneTimeToken();
    final connector = path.contains('?') ? '&' : '?';
    return "$path${connector}oauth_token=$accessToken";
  }
}

class _Inherited extends InheritedWidget {
  final ApiData data;

  _Inherited({
    Widget child,
    this.data,
    Key key,
  }) : super(child: child, key: key);

  @override
  bool updateShouldNotify(_Inherited old) => true;
}

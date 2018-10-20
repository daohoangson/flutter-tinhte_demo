import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tinhte_api/api.dart';
import 'package:tinhte_api/batch_controller.dart';
import 'package:tinhte_api/oauth_token.dart';
import 'package:tinhte_api/user.dart';

import '../screens/login.dart';
import '../constants.dart';

final _oauthTokenRegEx = RegExp(r'oauth_token=.+(&|$)');

typedef void ApiAction(ApiData apiData);

void prepareForApiAction(BuildContext context, ApiAction onReady,
    {ApiAction onError}) async {
  final apiData = ApiInheritedWidget.of(context);
  final token = await apiData._getOrRefreshToken();
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

Future showApiErrorDialog(BuildContext context, String title, error) =>
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
            title: Text(title),
            content: Text(error is ApiError ? error.message : error.toString()),
          ),
    );

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
      (context.inheritFromWidgetOfExactType(_ApiDataInheritedWidget)
              as _ApiDataInheritedWidget)
          .data;
}

class ApiData extends State<ApiInheritedWidget> {
  ApiWrapper get api => ApiWrapper(this);

  OauthToken _token;
  final List<ApiTokenListener> _tokenListeners = List();
  User _user;
  final List<ApiUserListener> _userListeners = List();

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
      _ApiDataInheritedWidget(child: widget.child, data: this);

  VoidCallback addApiTokenListener(ApiTokenListener listener) {
    _tokenListeners.add(listener);

    // notify right away when a new listener is added
    listener(_token);

    return () => _tokenListeners.remove(listener);
  }

  VoidCallback addApiUserListener(ApiUserListener listener) {
    var __removed = false;
    _userListeners.add(listener);

    // notify right away when a new listener is added
    _fetchUser().then((user) {
      if (__removed) return;
      listener(_token, user);
    });

    return () {
      __removed = true;
      _userListeners.remove(listener);
    };
  }

  Future<User> _fetchUser() async {
    if (_token == null) return Future.value(null);
    if (_user != null) return _user;

    final usersMe = "users/me?oauth_token=${_token.accessToken}";
    final json = await api.getJson(usersMe);
    final m = json as Map<String, dynamic>;
    final newUser = m.containsKey('user') ? User.fromJson(m['user']) : null;
    _setUser(newUser);

    return newUser;
  }

  Future<OauthToken> _getOrRefreshToken() async {
    if (_token == null) return Future.value(null);
    if (_token.expiresAt.isAfter(DateTime.now())) return _token;

    // TODO: handle concurrent request for token better
    // with the current implementation, our caller will get `null`
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

    for (final listener in _tokenListeners) {
      try {
        listener(value);
      } catch (e) {
        // print debug info then ignore
        debugPrint("Token listener $listener error: $e");
      }
    }

    setState(() => _token = value);

    if (value != null) {
      _fetchUser();
    } else {
      _setUser(null);
    }
  }

  void _setUser(User value) {
    for (final listener in _userListeners) {
      try {
        listener(_token, value);
      } catch (e) {
        // print debug info then ignore
        debugPrint("User listener $listener error: $e");
      }
    }

    setState(() => _user = value);
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
    return "${path.replaceAll(_oauthTokenRegEx, '')}${connector}oauth_token=$accessToken";
  }
}

class _ApiDataInheritedWidget extends InheritedWidget {
  final ApiData data;

  _ApiDataInheritedWidget({
    Widget child,
    this.data,
    Key key,
  }) : super(child: child, key: key);

  @override
  bool updateShouldNotify(_ApiDataInheritedWidget old) => true;
}

typedef void ApiTokenListener(OauthToken token);

typedef void ApiUserListener(OauthToken token, User user);

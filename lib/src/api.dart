import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tinhte_api/api.dart';
import 'package:tinhte_api/oauth_token.dart';
import 'package:tinhte_api/user.dart';

import 'screens/login.dart';
import 'constants.dart';

final _oauthTokenRegEx = RegExp(r'oauth_token=.+(&|$)');

Future apiBatch(State state, VoidCallback fetches,
    {ApiOnSuccess<bool> onSuccess,
    ApiOnError onError,
    VoidCallback onComplete}) {
  final apiData = ApiInheritedWidget.withoutInheritance(state.context);
  final batch = apiData._api.newBatch(path: apiData._appendOauthToken('batch'));

  fetches();

  return _setupApiFuture(state, batch.fetch(), onSuccess, onError, onComplete);
}

Future apiDelete(State state, path,
    {VoidCallback onComplete, ApiOnError onError, ApiOnJsonMap onSuccess}) {
  final apiData = ApiInheritedWidget.withoutInheritance(state.context);
  final future = apiData._api.deleteJson(apiData._appendOauthToken(path));
  return _setupApiJsonHandlers(state, future, onSuccess, onError, onComplete);
}

Future apiGet(State state, path,
    {VoidCallback onComplete, ApiOnError onError, ApiOnJsonMap onSuccess}) {
  final apiData = ApiInheritedWidget.withoutInheritance(state.context);
  final future = apiData._api.getJson(apiData._appendOauthToken(path));
  return _setupApiJsonHandlers(state, future, onSuccess, onError, onComplete);
}

Future apiPost(State state, path,
    {Map<String, String> bodyFields,
    VoidCallback onComplete,
    ApiOnError onError,
    ApiOnJsonMap onSuccess}) {
  final apiData = ApiInheritedWidget.withoutInheritance(state.context);
  final future = apiData._api
      .postJson(apiData._appendOauthToken(path), bodyFields: bodyFields);
  return _setupApiJsonHandlers(state, future, onSuccess, onError, onComplete);
}

Future login(State state, String username, String password,
    {VoidCallback onComplete,
    ApiOnError onError,
    ApiOnSuccess<OauthToken> onSuccess}) {
  final apiData = ApiInheritedWidget.withoutInheritance(state.context);
  final future = apiData._api.login(username, password).then((token) {
    apiData._setToken(token);
    return token;
  });
  return _setupApiFuture(state, future, onSuccess, onError, onComplete);
}

void prepareForApiAction(State state, VoidCallback onReady,
    {VoidCallback onError}) async {
  final apiData = ApiInheritedWidget.withoutInheritance(state.context);
  final token = await apiData._getOrRefreshToken();
  if (!state.mounted) return;

  if (token == null) {
    final loggedIn = await pushLoginScreen(state.context);
    if (loggedIn != true) {
      if (onError != null) onError();
      return;
    }
  }

  onReady();
}

Future showApiErrorDialog(BuildContext context, error,
        {String title = 'Api Error'}) =>
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
            title: Text(title),
            content: Text(error is ApiError ? error.message : error.toString()),
          ),
    );

Future _setupApiFuture<T>(State state, Future<T> future,
    ApiOnSuccess<T> onSuccess, ApiOnError onError, VoidCallback onComplete) {
  Future f = future;

  if (onSuccess != null) {
    f = f.then((data) {
      if (!state.mounted) return;
      if (onSuccess == null) return;
      return onSuccess(data);
    });
  }

  f = f.catchError((error) {
    if (!state.mounted) return;
    if (onError != null) return onError(error);
    showApiErrorDialog(state.context, error);
  });

  if (onComplete != null) {
    f.whenComplete(() {
      if (!state.mounted) return;
      if (onComplete == null) return;
      onComplete();
    });
  }

  return f;
}

Future _setupApiJsonHandlers(State state, Future future, ApiOnJsonMap onSuccess,
    ApiOnError onError, VoidCallback onComplete) {
  final _onSuccess = onSuccess != null
      ? (json) {
          if (json is! Map) {
            debugPrint("Api response is not a Map: ${json.toString()}");
            return;
          }
          onSuccess(json);
        }
      : null;

  return _setupApiFuture<dynamic>(
      state, future, _onSuccess, onError, onComplete);
}

typedef void ApiOnSuccess<T>(T data);
typedef void ApiOnJsonMap(Map jsonMap);
typedef void ApiOnError(error);

class ApiInheritedWidget extends StatefulWidget {
  final Api api;
  final Widget child;

  ApiInheritedWidget({
    Key key,
    @required String apiRoot,
    @required this.child,
    @required String clientId,
    @required String clientSecret,
  })  : api = Api(apiRoot, clientId, clientSecret)
          ..httpHeaders['Api-Bb-Code-Chr'] = '!youtube'
          ..httpHeaders['Api-Post-Tree'] = '1',
        super(key: key);

  @override
  State<ApiInheritedWidget> createState() => ApiData();

  static ApiData of(BuildContext context) =>
      (context.inheritFromWidgetOfExactType(_ApiDataInheritedWidget)
              as _ApiDataInheritedWidget)
          .data;

  static ApiData withoutInheritance(BuildContext context) =>
      (context.ancestorWidgetOfExactType(_ApiDataInheritedWidget)
              as _ApiDataInheritedWidget)
          .data;
}

class ApiData extends State<ApiInheritedWidget> {
  Api get _api => widget.api;

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

  void logout() => _setToken(null);

  String _appendOauthToken(String path) {
    final accessToken = _token?.accessToken ?? _api.buildOneTimeToken();
    final connector = path.contains('?') ? '&' : '?';
    return "${path.replaceAll(_oauthTokenRegEx, '')}${connector}oauth_token=$accessToken";
  }

  Future<User> _fetchUser() async {
    if (_token == null) return null;
    if (_user != null) return _user;

    final usersMe = "users/me?oauth_token=${_token.accessToken}";
    try {
      final json = await widget.api.getJson(usersMe);
      final m = json as Map;
      final newUser = m.containsKey('user') ? User.fromJson(m['user']) : null;
      _setUser(newUser);

      return newUser;
    } catch (e) {
      debugPrint("_fetchUser encountered an error: ${e.toString()}");
      return null;
    }
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

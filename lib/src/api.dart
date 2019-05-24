import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tinhte_api/api.dart';
import 'package:tinhte_api/oauth_token.dart';
import 'package:tinhte_api/user.dart';

import 'screens/login.dart';
import 'config.dart';
import 'constants.dart';

final _oauthTokenRegEx = RegExp(r'oauth_token=.+(&|$)');

void apiDelete(State state, String path,
        {Map<String, String> bodyFields,
        VoidCallback onComplete,
        ApiOnError onError,
        ApiOnJsonMap onSuccess}) =>
    _setupApiJsonHandlers(
      state,
      (d) => d.api.deleteJson(
            d._appendOauthToken(path),
            bodyFields: bodyFields,
          ),
      onSuccess,
      onError,
      onComplete,
    );

void apiGet(State state, String path,
        {VoidCallback onComplete,
        ApiOnError onError,
        ApiOnJsonMap onSuccess}) =>
    _setupApiJsonHandlers(
      state,
      (d) => d.api.getJson(d._appendOauthToken(path)),
      onSuccess,
      onError,
      onComplete,
    );

void apiPost(State state, String path,
        {Map<String, String> bodyFields,
        Map<String, File> fileFields,
        VoidCallback onComplete,
        ApiOnError onError,
        ApiOnJsonMap onSuccess}) =>
    _setupApiJsonHandlers(
      state,
      (d) => d.api.postJson(
            d._appendOauthToken(path),
            bodyFields: bodyFields,
            fileFields: fileFields,
          ),
      onSuccess,
      onError,
      onComplete,
    );

void prepareForApiAction(
  State state,
  VoidCallback onReady, {
  VoidCallback onError,
}) async {
  final apiAuth = ApiAuth.of(state.context, listen: false);

  if (!apiAuth.hasToken) {
    final loggedIn = await Navigator.push(state.context, LoginScreenRoute());
    if (loggedIn != true) {
      if (onError != null) onError();
      return;
    }
  }

  onReady();
}

Future showApiErrorDialog(
  BuildContext context,
  dynamic error, {
  String title = 'Api Error',
}) =>
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
            title: Text(title),
            content: Text(
              error is ApiError
                  ? error.message
                  : "${error.runtimeType.toString()}: ${error.toString()}",
            ),
          ),
    );

void _setupApiCompleter<T>(
  State state,
  Completer<T> completer,
  ApiOnSuccess<T> onSuccess,
  ApiOnError onError,
  VoidCallback onComplete,
) {
  var f = completer.future;

  if (onSuccess != null) {
    f = f.then(
      (data) => (state.mounted && onSuccess != null) ? onSuccess(data) : null,
    );
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
}

void _setupApiJsonHandlers(
  State state,
  ApiFetch fetch,
  ApiOnJsonMap onSuccess,
  ApiOnError onError,
  VoidCallback onComplete,
) {
  final aas = Provider.of<_ApiAppState>(state.context, listen: false);
  final completer = Completer();
  aas._enqueue(() => completer.complete(fetch(aas)));

  return _setupApiCompleter<dynamic>(
    state,
    completer,
    onSuccess != null
        ? (json) {
            if (json is! Map) {
              print(json);
              throw new ApiError(message: 'Unexpected api response');
            }
            return onSuccess(json);
          }
        : null,
    onError,
    onComplete,
  );
}

typedef Future ApiFetch(_ApiAppState aas);
typedef void ApiMethod(
  State state,
  String path, {
  VoidCallback onComplete,
  ApiOnError onError,
  ApiOnJsonMap onSuccess,
});
typedef T ApiOnSuccess<T>(T data);
typedef void ApiOnJsonMap(Map jsonMap);
typedef void ApiOnError(error);

class ApiApp extends StatefulWidget {
  final Api api;
  final Widget child;

  ApiApp(this.child, {Key key})
      : api = Api(configApiRoot, configClientId, configClientSecret)
          ..httpHeaders['Api-Bb-Code-Chr'] = '1'
          ..httpHeaders['Api-Post-Tree'] = '1',
        super(key: key);

  @override
  State<ApiApp> createState() => _ApiAppState();
}

class _ApiAppState extends State<ApiApp> {
  OauthToken _token;
  bool _tokenHasBeenSet = false;
  User _user = User(0);

  List<VoidCallback> _queue;

  Api get api => widget.api;

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((SharedPreferences prefs) {
      final clientId = prefs.getString(kPrefKeyTokenClientId);
      if (clientId != api.clientId) {
        return _setToken(null, savePref: false);
      }

      final t = prefs.getString(kPrefKeyTokenAccessToken);
      final expiresAtKey = kPrefKeyTokenExpiresAtMillisecondsSinceEpoch;
      final expiresAt = prefs.getInt(expiresAtKey) ?? 0;
      final rt = prefs.getString(kPrefKeyTokenRefreshToken);
      final scope = prefs.getString(kPrefKeyTokenScope);
      final userId = prefs.getInt(kPrefKeyTokenUserId);
      if (t?.isNotEmpty != true || expiresAt < 1) {
        return _setToken(null, savePref: false);
      }

      final now = DateTime.now().millisecondsSinceEpoch;
      final ei = ((expiresAt - now) / 1000).floor();
      debugPrint("Restored token $t, expires in $ei, refresh token $rt");
      _setToken(OauthToken(t, ei, rt, scope, userId), savePref: false);
    });
  }

  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: [
          Provider<ApiAuth>.value(value: ApiAuth(this)),
          Provider<User>.value(value: _user),
          Provider<_ApiAppState>.value(value: this),
        ],
        child: widget.child,
      );

  String _appendOauthToken(String path) {
    final accessToken = _token?.accessToken ?? api.buildOneTimeToken();
    final connector = path.contains('?') ? '&' : '?';
    return "${path.replaceAll(_oauthTokenRegEx, '')}${connector}oauth_token=$accessToken";
  }

  void _enqueue(VoidCallback callback) {
    Timer.run(_dequeue);

    _queue ??= List();
    _queue.add(callback);
  }

  void _dequeue() {
    if (!_tokenHasBeenSet) return;
    if (_token?.hasExpired == true) return _refreshToken();

    final __callbacks = _queue;
    _queue = null;
    if (__callbacks?.isNotEmpty != true) return;
    if (__callbacks.length == 1) return __callbacks.first();

    final batch = api.newBatch(path: _appendOauthToken('batch'));
    for (final __callback in __callbacks) {
      try {
        __callback();
      } catch (e) {
        // print and ignore to avoid affecting others in batch
        // this should not happen in normal circumstances because
        // _setupApiFuture as a default onError handler
        print(e);
      }
    }
    batch.fetch();
  }

  void _fetchUser() {
    _enqueue(() async {
      if (_token == null) return;

      try {
        final json = await api.getJson(_appendOauthToken('users/me'));
        if (json is Map && json.containsKey('user')) {
          final user = User.fromJson(json['user']);
          setState(() => _user = user);
        }
      } on ApiError catch (ae) {
        debugPrint("_fetchUser encountered an api error: ${ae.message}");
      } catch (e) {
        print(e);
      }
    });
  }

  void _refreshToken() {
    api
        .refreshToken(_token)
        .then((refreshedToken) => _setToken(refreshedToken))
        .catchError((_) => _setToken(null));
  }

  void _setToken(OauthToken value, {bool savePref = true}) {
    if (savePref) {
      SharedPreferences.getInstance().then((SharedPreferences prefs) {
        prefs.setString(kPrefKeyTokenAccessToken, value?.accessToken);
        prefs.setString(kPrefKeyTokenClientId, api.clientId);
        prefs.setInt(kPrefKeyTokenExpiresAtMillisecondsSinceEpoch,
            value?.expiresAt?.millisecondsSinceEpoch);
        prefs.setString(kPrefKeyTokenRefreshToken, value?.refreshToken);
        prefs.setString(kPrefKeyTokenScope, value?.scope);
        prefs.setInt(kPrefKeyTokenUserId, value?.userId);
        debugPrint("Saved token ${value?.accessToken}, "
            "expires at ${value?.expiresAt}, "
            "refresh token ${value?.refreshToken}");
      });
    }

    _token = value;
    _tokenHasBeenSet = true;

    if (value != null) {
      _fetchUser();
    } else if (_user.userId != 0) {
      setState(() => _user = User(0));
    }

    _dequeue();
  }
}

class ApiAuth {
  final _ApiAppState aas;

  ApiAuth(this.aas);

  Api get api => aas.api;

  bool get hasToken => aas._token != null;
  OauthToken get token => aas._token;

  void setToken(OauthToken token) => aas._setToken(token);

  static ApiAuth of(BuildContext context, {bool listen = true}) =>
      Provider.of<ApiAuth>(context, listen: listen);
}

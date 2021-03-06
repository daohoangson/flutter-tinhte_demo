import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_api/api.dart';
import 'package:the_api/oauth_token.dart';
import 'package:the_api/user.dart';
import 'package:the_app/src/intl.dart';
import 'package:the_app/src/screens/login.dart';
import 'package:the_app/src/config.dart';
import 'package:the_app/src/constants.dart';

final _oauthTokenRegEx = RegExp(r'oauth_token=.+(&|$)');

void apiDelete(ApiCaller caller, String path,
        {Map<String, String> bodyFields,
        VoidCallback onComplete,
        ApiOnError onError,
        ApiOnJsonMap onSuccess}) =>
    _setupApiJsonHandlers(
      caller,
      (d) => d.api.deleteJson(
        d._appendOauthToken(path),
        bodyFields: bodyFields,
      ),
      onSuccess,
      onError,
      onComplete,
    );

void apiGet(ApiCaller caller, String path,
        {VoidCallback onComplete,
        ApiOnError onError,
        ApiOnJsonMap onSuccess}) =>
    _setupApiJsonHandlers(
      caller,
      (d) => d.api.getJson(d._appendOauthToken(path)),
      onSuccess,
      onError,
      onComplete,
    );

void apiPost(ApiCaller caller, String path,
        {Map<String, String> bodyFields,
        Map<String, File> fileFields,
        VoidCallback onComplete,
        ApiOnError onError,
        ApiOnJsonMap onSuccess}) =>
    _setupApiJsonHandlers(
      caller,
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
  BuildContext context,
  VoidCallback onReady, {
  VoidCallback onError,
}) async {
  final apiAuth = ApiAuth.of(context, listen: false);

  if (!apiAuth.hasToken) {
    final loggedIn = await Navigator.push(context, LoginScreenRoute());
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
  String title,
}) =>
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title ?? l(context).apiError),
        content: error is ApiError
            ? error.isHtml
                ? HtmlWidget(error.message)
                : Text(
                    (error is ApiErrorUnexpectedResponse ||
                            error is ApiErrorUnexpectedStatusCode)
                        ? l(context).apiUnexpectedResponse
                        : error.message,
                  )
            : Text("${error.runtimeType.toString()}: ${error.toString()}"),
      ),
    );

void _setupApiCompleter<T>(
  ApiCaller caller,
  Completer<T> completer,
  ApiOnSuccess<T> onSuccess,
  ApiOnError onError,
  VoidCallback onComplete,
) {
  var f = completer.future;

  if (onSuccess != null) {
    f = f.then(
      (data) => (caller.canReceiveCallback && onSuccess != null)
          ? onSuccess(data)
          : null,
    );
  }

  f = f.catchError((error) {
    if (caller.canReceiveCallback) {
      if (onError != null) {
        onError(error);
      } else {
        showApiErrorDialog(caller.context, error);
      }
    }
  });

  if (onComplete != null) {
    f.whenComplete(() {
      if (!caller.canReceiveCallback) return;
      if (onComplete == null) return;
      onComplete();
    });
  }
}

void _setupApiJsonHandlers(
  ApiCaller caller,
  ApiFetch fetch,
  ApiOnJsonMap onSuccess,
  ApiOnError onError,
  VoidCallback onComplete,
) {
  final aas = Provider.of<_ApiAppState>(caller.context, listen: false);
  final completer = Completer();
  aas._enqueue(() => completer.complete(fetch(aas)));

  return _setupApiCompleter<dynamic>(
    caller,
    completer,
    onSuccess != null
        ? (json) {
            if (json is! Map) throw new ApiErrorUnexpectedResponse(json);
            return onSuccess(json);
          }
        : null,
    onError,
    onComplete,
  );
}

typedef Future ApiFetch(_ApiAppState aas);
typedef void ApiMethod(
  ApiCaller caller,
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

  ApiApp({
    @required this.child,
    Key key,
  })  : assert(child != null),
        api = Api(config.apiRoot, config.clientId, config.clientSecret)
          ..httpHeaders['Api-Bb-Code-Chr'] = '1'
          ..httpHeaders['Api-Post-Tree'] = '1',
        super(key: key);

  @override
  State<ApiApp> createState() => _ApiAppState();
}

class _ApiAppState extends State<ApiApp> {
  final visitor = User.zero();

  var _isRefreshingToken = false;
  List<VoidCallback> _queue;
  OauthToken _token;
  var _tokenHasBeenSet = false;

  Api get api => widget.api;

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((prefs) {
      final clientId = prefs.getString(kPrefKeyTokenClientId);
      if (clientId != api.clientId) return _setToken(null, savePref: false);

      final accessToken = prefs.getString(kPrefKeyTokenAccessToken);
      final expiresAtKey = kPrefKeyTokenExpiresAtMillisecondsSinceEpoch;
      final expiresAt = prefs.getInt(expiresAtKey) ?? 0;
      final refreshToken = prefs.getString(kPrefKeyTokenRefreshToken);
      final scope = prefs.getString(kPrefKeyTokenScope);
      final userId = prefs.getInt(kPrefKeyTokenUserId);
      if (accessToken?.isNotEmpty != true || expiresAt < 1) {
        return _setToken(null, savePref: false);
      }

      final now = DateTime.now().millisecondsSinceEpoch;
      final expiresIn = ((expiresAt - now) / 1000).floor();
      final token = OauthToken(
        accessToken: accessToken,
        refreshToken: refreshToken,
        scope: scope,
        userId: userId,
        expiresIn: expiresIn,
        millisecondsSinceEpoch: now,
        obtainMethod: ObtainMethod.storage,
      );

      _setToken(token, savePref: false);
    });
  }

  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: [
          Provider<ApiAuth>.value(value: ApiAuth(this)),
          ChangeNotifierProvider<User>.value(value: visitor),
          Provider<_ApiAppState>.value(value: this),
        ],
        child: widget.child,
      );

  String _appendOauthToken(String path) {
    final accessToken = _token?.accessToken ?? api.buildOneTimeToken();
    final connector = path.contains('?') ? '&' : '?';
    return "${path.replaceAll(_oauthTokenRegEx, '')}${connector}oauth_token=$accessToken";
  }

  void _enqueue(VoidCallback callback, {bool scheduleDequeue = true}) {
    if (scheduleDequeue) Timer.run(_dequeue);

    _queue ??= [];
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
        // print and ignore to avoid affecting other callbacks in the same batch
        print(e);
      }
    }
    batch.fetch();
  }

  void _fetchUser(bool scheduleDequeue) => _enqueue(() async {
        if (_token == null) return;

        try {
          final json = await api.getJson(_appendOauthToken('users/me'));
          if (json is Map && json.containsKey('user')) {
            visitor.update(json['user']);
          }
        } on ApiError catch (ae) {
          debugPrint("_fetchUser encountered an api error: ${ae.message}");
        } catch (e) {
          print(e);
        }
      }, scheduleDequeue: scheduleDequeue);

  void _refreshToken() {
    if (_isRefreshingToken) return;
    _isRefreshingToken = true;

    api
        .refreshToken(_token)
        .then((refreshedToken) => _setToken(refreshedToken))
        .catchError((_) => _setToken(null))
        .whenComplete(() => _isRefreshingToken = false);
  }

  void _setToken(OauthToken value, {bool savePref = true}) async {
    if (savePref) {
      final prefs = await SharedPreferences.getInstance();

      prefs.setString(kPrefKeyTokenAccessToken, value?.accessToken ?? '');
      prefs.setString(kPrefKeyTokenClientId, api.clientId ?? '');
      prefs.setInt(
          kPrefKeyTokenExpiresAtMillisecondsSinceEpoch, value?.expiresAt ?? 0);
      prefs.setString(kPrefKeyTokenRefreshToken, value?.refreshToken ?? '');
      prefs.setString(kPrefKeyTokenScope, value?.scope ?? '');
      prefs.setInt(kPrefKeyTokenUserId, value?.userId ?? 0);
      debugPrint("Saved token ${value?.accessToken}, "
          "expires at ${value?.expiresAt}, "
          "refresh token ${value?.refreshToken}");
    }

    _token = value;
    _tokenHasBeenSet = true;

    if (value != null) {
      _fetchUser(savePref);
      return;
    }

    if (visitor.userId != 0) {
      visitor.reset();
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

abstract class ApiCaller {
  bool get canReceiveCallback;
  BuildContext get context;

  static ApiCaller stateful(State state) => _ApiCallerStateful(state);
  static ApiCaller stateless(BuildContext context) =>
      _ApiCallerStateless(context);
}

class _ApiCallerStateful extends ApiCaller {
  final State _state;

  _ApiCallerStateful(this._state);

  bool get canReceiveCallback => _state.mounted;
  BuildContext get context => _state.context;
}

class _ApiCallerStateless extends ApiCaller {
  final BuildContext context;

  _ApiCallerStateless(this.context);

  bool get canReceiveCallback => true;
}

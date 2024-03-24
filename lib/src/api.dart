import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:the_api/api.dart';
import 'package:the_api/oauth_token.dart';
import 'package:the_api/user.dart';
import 'package:the_app/src/intl.dart';
import 'package:the_app/src/screens/login.dart';
import 'package:the_app/src/config.dart';
import 'package:the_app/src/constants.dart';

final _oauthTokenRegEx = RegExp(r'oauth_token=.+(&|$)');

void apiDelete(ApiCaller caller, String path,
        {Map<String, String>? bodyFields,
        VoidCallback? onComplete,
        ApiOnError? onError,
        ApiOnJsonMap? onSuccess}) =>
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
        {VoidCallback? onComplete,
        ApiOnError? onError,
        ApiOnJsonMap? onSuccess}) =>
    _setupApiJsonHandlers(
      caller,
      (d) => d.api.getJson(d._appendOauthToken(path)),
      onSuccess,
      onError,
      onComplete,
    );

void apiPost(ApiCaller caller, String path,
        {Map<String, String>? bodyFields,
        Map<String, File>? fileFields,
        VoidCallback? onComplete,
        ApiOnError? onError,
        ApiOnJsonMap? onSuccess}) =>
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
  VoidCallback? onError,
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
  String? title,
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
  ApiOnSuccess<T>? onSuccess,
  ApiOnError? onError,
  VoidCallback? onComplete,
) {
  Future<void> f = completer.future;

  if (onSuccess != null) {
    f = completer.future.then(
      (data) => (caller.canReceiveCallback) ? onSuccess(data) : data,
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
      onComplete();
    });
  }
}

void _setupApiJsonHandlers(
  ApiCaller caller,
  _ApiFetch fetch,
  ApiOnJsonMap? onSuccess,
  ApiOnError? onError,
  VoidCallback? onComplete,
) {
  final aas = Provider.of<_ApiAppState>(caller.context, listen: false);
  final completer = Completer();
  aas._enqueue(() => completer.complete(fetch(aas)));

  return _setupApiCompleter<dynamic>(
    caller,
    completer,
    onSuccess != null
        ? (json) {
            if (json is! Map) throw ApiErrorUnexpectedResponse(json);
            return onSuccess(json);
          }
        : null,
    onError,
    onComplete,
  );
}

typedef _ApiFetch = Future Function(_ApiAppState aas);
typedef ApiMethod = void Function(
  ApiCaller caller,
  String path, {
  VoidCallback? onComplete,
  ApiOnError? onError,
  ApiOnJsonMap? onSuccess,
});
typedef ApiOnSuccess<T> = T Function(T data);
typedef ApiOnJsonMap = void Function(Map jsonMap);
typedef ApiOnError = void Function(dynamic error);

class ApiApp extends StatefulWidget {
  final Widget child;
  final bool enableBatch;

  const ApiApp({
    required this.child,
    this.enableBatch = true,
    super.key,
  });

  @override
  State<ApiApp> createState() => _ApiAppState();
}

class _ApiAppState extends State<ApiApp> {
  late final Api api;
  final secureStorage = const FlutterSecureStorage();
  final visitor = User.zero();

  var _isRefreshingToken = false;
  List<VoidCallback>? _queue;
  OauthToken? _token;
  var _tokenHasBeenSet = false;

  String get _secureStorageKeyToken =>
      kSecureStorageKeyPrefixToken + api.clientId;

  @override
  void initState() {
    super.initState();

    api = Api(
      context.read<http.Client>(),
      apiRoot: config.apiRoot,
      clientId: config.clientId,
      clientSecret: config.clientSecret,
      enableBatch: widget.enableBatch,
      httpHeaders: const {
        'Api-Bb-Code-Chr': '1',
        'Api-Post-Tree': '1',
      },
    );

    secureStorage.read(key: _secureStorageKeyToken).then<OauthToken?>(
      (value) {
        try {
          final json = jsonDecode(value ?? '');
          return OauthToken.fromJson(json, ObtainMethod.storage);
        } catch (_) {
          return null;
        }
      },
      onError: (_, __) => null,
    ).then((token) => _setToken(token, savePref: false));
  }

  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: [
          Provider<ApiAuth>.value(value: ApiAuth._(this)),
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

    final queue = _queue ??= [];
    queue.add(callback);
  }

  void _dequeue() {
    if (!_tokenHasBeenSet) return;

    final token = _token;
    if (token != null && token.hasExpired) return _refreshToken(token);

    final callbacks = _queue;
    _queue = null;
    if (callbacks == null || callbacks.isEmpty) return;
    if (callbacks.length == 1) return callbacks.first();

    final batch = api.newBatch(path: _appendOauthToken('batch'));
    for (final callback in callbacks) {
      try {
        callback();
      } catch (e) {
        // print and ignore to avoid affecting other callbacks in the same batch
        debugPrint('callback error: $e');
      }
    }
    batch.fetch();
  }

  void _fetchUser() => _enqueue(() async {
        if (_token == null) return;

        try {
          final json = await api.getJson(_appendOauthToken('users/me'));
          if (json is Map && json.containsKey('user')) {
            visitor.update(json['user']);
          }
        } on ApiError catch (ae) {
          debugPrint("_fetchUser encountered an api error: ${ae.message}");
        } catch (e) {
          debugPrint('api error: $e');
        }
      }, scheduleDequeue: false);

  void _refreshToken(OauthToken token) {
    if (_isRefreshingToken) return;
    _isRefreshingToken = true;

    api
        .refreshToken(token)
        .then((refreshedToken) => _setToken(refreshedToken))
        .catchError((_) => _setToken(null))
        .whenComplete(() => _isRefreshingToken = false);
  }

  void _setToken(OauthToken? value, {bool savePref = true}) async {
    if (savePref) {
      try {
        await secureStorage.write(
          key: _secureStorageKeyToken,
          value: jsonEncode(value),
        );
        debugPrint("Saved token ${value?.accessToken}, "
            "expires at ${value?.expiresAt}, "
            "refresh token ${value?.refreshToken}");
      } catch (error) {
        if (value != null) {
          debugPrint('Failed saving token ${value.accessToken}: $error');
        }
      }
    }

    _token = value;
    _tokenHasBeenSet = true;

    if (visitor.userId != 0) visitor.reset();
    if (value != null) _fetchUser();
    _dequeue();
  }
}

class ApiAuth {
  final _ApiAppState _aas;

  ApiAuth._(this._aas);

  Api get api => _aas.api;

  bool get hasToken => _aas._token != null;
  OauthToken? get token => _aas._token;

  void setToken(OauthToken? token) => _aas._setToken(token);

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

  @override
  bool get canReceiveCallback => _state.mounted;
  @override
  BuildContext get context => _state.context;
}

class _ApiCallerStateless extends ApiCaller {
  @override
  final BuildContext context;

  _ApiCallerStateless(this.context);

  @override
  bool get canReceiveCallback => true;
}

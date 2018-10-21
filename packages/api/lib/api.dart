import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:async/async.dart';
import 'package:http/http.dart';
import 'package:path/path.dart';

import 'batch_controller.dart';
import 'oauth_token.dart';
import 'src/batch.dart';
import 'src/crypto.dart';

part 'src/api_internal.dart';

class Api {
  final Client httpClient = Client();
  final Map<String, String> httpHeaders = Map();

  final String _apiRoot;
  final String _clientId;
  final String _clientSecret;

  Batch _batch;

  String get clientId => _clientId;
  Response get latestResponse => _latestResponse;
  int get requestCount => _requestCount;

  Api(String apiRoot, this._clientId, this._clientSecret)
      : _apiRoot = apiRoot.replaceAll(RegExp(r'/$'), '');

  String buildUrl(String path) {
    if (path.startsWith('http')) {
      return path;
    }

    final safePath = path.replaceFirst('?', '&');

    return "${this._apiRoot}?$safePath";
  }

  String buildOneTimeToken({
    int userId = 0,
    String accessToken = '',
    int ttl = 3600,
  }) {
    final now = (DateTime.now().millisecondsSinceEpoch / 1000).floor();
    final timestamp = now + ttl;
    final once = md5("$userId$timestamp$accessToken$_clientSecret");
    return "$userId,$timestamp,$once,$_clientId";
  }

  close() {
    httpClient.close();
  }

  BatchController newBatch({String path = 'batch'}) {
    if (_batch == null) {
      final batch = Batch(path: path);
      _batch = batch;
      return BatchController(batch, () => _fetchBatch(batch));
    }

    return BatchController(
        _batch,
        () => _batch.future.then(
              (j) => Future.value(true),
              onError: (e) => Future.value(false),
            ));
  }

  Future<OauthToken> login(String username, String password) async {
    final json = await postJson('oauth/token', bodyFields: {
      "grant_type": "password",
      "client_id": _clientId,
      "client_secret": _clientSecret,
      "username": username,
      "password": password,
    });

    return OauthToken.fromJson(json);
  }

  Future<OauthToken> refreshToken(String refreshToken) async {
    final json = await postJson('oauth/token', bodyFields: {
      "grant_type": "refresh_token",
      "client_id": _clientId,
      "client_secret": _clientSecret,
      "refresh_token": refreshToken,
    });

    return OauthToken.fromJson(json);
  }

  Future<dynamic> deleteJson(String path) {
    return sendRequest('DELETE', path, parseJson: true);
  }

  Future<dynamic> getJson(String path) {
    return sendRequest('GET', path, parseJson: true);
  }

  Future<dynamic> postJson(String path,
      {Map<String, String> bodyFields, Map<String, File> fileFields}) {
    return sendRequest('POST', path,
        bodyFields: bodyFields, fileFields: fileFields, parseJson: true);
  }

  Future<dynamic> putJson(String path, {Map<String, String> bodyFields}) {
    return sendRequest('PUT', path, bodyFields: bodyFields, parseJson: true);
  }

  Future<bool> _fetchBatch(Batch batch) async {
    if (batch.length == 0) {
      _batch = null;
      return Future.value(false);
    }

    final json = await sendRequest(
      'POST',
      batch.path,
      bodyJson: batch.bodyJson,
      parseJson: true,
    );
    final handled = batch.handleResponse(json);

    _batch = null;
    return handled;
  }

  Future sendRequest(String method, String path,
      {Map<String, String> bodyFields,
      String bodyJson,
      Map<String, File> fileFields,
      parseJson: false}) {
    if (_batch != null && bodyJson == null && fileFields == null && parseJson) {
      return _batch.newJob(method, path, bodyFields);
    }

    return _sendRequest(httpClient, method, buildUrl(path),
        bodyFields: bodyFields,
        bodyJson: bodyJson,
        fileFields: fileFields,
        headers: httpHeaders,
        parseJson: parseJson);
  }
}

class ApiError {
  final String message;

  ApiError({String message, List<String> messages})
      : message = messages != null ? messages.join(', ') : message;
}

import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart';

import 'internal/batch.dart';
import 'internal/batch_controller.dart';
import 'model/oauth_token.dart';

part 'internal/api.dart';

class Api {

  final Client httpClient = Client();
  final Map<String, String> httpHeaders = Map();

  final String _apiRoot;
  final String _clientId;
  final String _clientSecret;

  Batch _batch;

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

  close() {
    httpClient.close();
  }

  BatchController newBatch() {
    if (_batch == null) {
      final batch = Batch();
      _batch = batch;
      return BatchController(batch, () => _fetchBatch(batch));
    }

    return BatchController(_batch, () => Future.value(false));
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

  Future<dynamic> postJson(String path, {Map<String, String> bodyFields}) {
    return sendRequest('POST', path, bodyFields: bodyFields, parseJson: true);
  }

  Future<dynamic> putJson(String path, {Map<String, String> bodyFields}) {
    return sendRequest('PUT', path, bodyFields: bodyFields, parseJson: true);
  }

  Future<bool> _fetchBatch(Batch batch) async {
    if (batch.length == 0) {
      return Future.value(false);
    }

    final json = await sendRequest('POST', 'batch',
        bodyJson: batch.buildBodyJson(), parseJson: true);
    return batch.handleResponse(json);
  }

  Future sendRequest(String method, String path,
      {Map<String, String> bodyFields, String bodyJson, parseJson: false}) {
    if (_batch != null && bodyJson == null && parseJson) {
      return _batch.newJob(method, path, bodyFields);
    }

    return _sendRequest(httpClient, method, buildUrl(path),
        bodyFields: bodyFields,
        bodyJson: bodyJson,
        headers: httpHeaders,
        parseJson: parseJson);
  }
}

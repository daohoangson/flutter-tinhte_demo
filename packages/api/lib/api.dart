import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart';
import 'package:path/path.dart';

import 'batch_controller.dart';
import 'login_result.dart';
import 'oauth_token.dart';
import 'src/batch.dart';
import 'src/crypto.dart';

part 'src/api_internal.dart';
part 'src/api_login.dart';

class Api {
  final String apiRoot;
  final String clientId;
  final String clientSecret;
  final bool enableBatch;
  final Client _httpClient;
  final Map<String, String> _httpHeaders;

  Batch? _batch;
  var _requestCount = 0;

  Response? get latestResponse => _latestResponse;
  int get requestCount => _requestCount;

  Api(
    this._httpClient, {
    required String apiRoot,
    this.clientId = '',
    this.clientSecret = '',
    this.enableBatch = true,
    Map<String, String> httpHeaders = const {},
  })  : apiRoot = apiRoot.replaceAll(RegExp(r'/$'), ''),
        _httpHeaders = httpHeaders;

  String buildUrl(String path) {
    if (path.startsWith('http')) {
      return path;
    }

    final safePath = path.replaceFirst('?', '&');

    return "$apiRoot?$safePath";
  }

  String buildOneTimeToken({
    int userId = 0,
    String accessToken = '',
    int ttl = 3600,
  }) {
    final now = (DateTime.now().millisecondsSinceEpoch / 1000).floor();
    final timestamp = now + ttl;
    final once = md5("$userId$timestamp$accessToken$clientSecret");
    return "$userId,$timestamp,$once,$clientId";
  }

  close() {
    _httpClient.close();
  }

  BatchController newBatch({String path = 'batch'}) {
    final batch = _batch;
    if (batch == null) {
      final newBatch = Batch(path: path);
      _batch = newBatch;
      return BatchController(newBatch, () => _fetchBatch(newBatch));
    }

    return BatchController(
        batch,
        () => batch.future.then(
              (_) => Future.value(true),
              onError: (_) => Future.value(false),
            ));
  }

  Future<OauthToken?> refreshToken(OauthToken token) async {
    final refreshToken = token.refreshToken;
    if (refreshToken?.isNotEmpty != true) return null;

    final json = await postJson('oauth/token', bodyFields: {
      "grant_type": "refresh_token",
      "client_id": clientId,
      "client_secret": clientSecret,
      "refresh_token": refreshToken!,
    });

    return OauthToken.fromJson(json, token.obtainMethod);
  }

  Future<dynamic> deleteJson(String path, {Map<String, String>? bodyFields}) {
    return sendRequest('DELETE', path, bodyFields: bodyFields, parseJson: true);
  }

  Future<dynamic> getJson(String path) {
    return sendRequest('GET', path, parseJson: true);
  }

  Future<dynamic> postJson(String path,
      {Map<String, String>? bodyFields, Map<String, File>? fileFields}) {
    return sendRequest('POST', path,
        bodyFields: bodyFields, fileFields: fileFields, parseJson: true);
  }

  Future<dynamic> putJson(String path, {Map<String, String>? bodyFields}) {
    return sendRequest('PUT', path, bodyFields: bodyFields, parseJson: true);
  }

  Future<bool> _fetchBatch(Batch batch) async {
    if (batch == _batch) _batch = null;
    if (batch.length == 0) return false;

    try {
      final json = await sendRequest(
        'POST',
        batch.path,
        bodyJson: batch.bodyJson,
        parseJson: true,
      );
      return batch.handleResponse(json);
    } catch (error, stackTrace) {
      return batch.handleError(error, stackTrace);
    }
  }

  Future sendRequest(String method, String path,
      {Map<String, String>? bodyFields,
      String? bodyJson,
      Map<String, File>? fileFields,
      parseJson = false}) {
    final batch = _batch;
    if (enableBatch &&
        batch != null &&
        bodyJson == null &&
        fileFields == null &&
        parseJson) {
      return batch.newJob(method, path, params: bodyFields);
    }

    _requestCount++;
    return _sendRequest(_httpClient, method, buildUrl(path),
        bodyFields: bodyFields,
        bodyJson: bodyJson,
        fileFields: fileFields,
        headers: _httpHeaders,
        parseJson: parseJson);
  }
}

abstract class ApiError extends Error {
  String get message;

  bool get isHtml => false;

  @override
  String toString() => "Api error: $message";
}

class ApiErrorMapped extends ApiError {
  final Map<String, String> errors;

  ApiErrorMapped(this.errors);

  @override
  String get message => errors.values.join(', ');

  @override
  bool get isHtml => true;
}

class ApiErrorSingle extends ApiError {
  @override
  final String message;

  @override
  final bool isHtml;

  ApiErrorSingle(this.message, {this.isHtml = false});
}

class ApiErrorUnexpectedResponse extends ApiError {
  final dynamic body;

  ApiErrorUnexpectedResponse(this.body);

  @override
  String get message => 'Unexpected response: $body';
}

class ApiErrorUnexpectedStatusCode extends ApiError {
  final int statusCode;

  ApiErrorUnexpectedStatusCode(this.statusCode);

  @override
  String get message => 'Unexpected status code: $statusCode';
}

class ApiErrors extends ApiError {
  final Iterable<String> messages;

  ApiErrors(this.messages);

  @override
  String get message => messages.join(', ');

  @override
  bool get isHtml => true;

  @override
  String toString() => "Api errors: $messages";
}

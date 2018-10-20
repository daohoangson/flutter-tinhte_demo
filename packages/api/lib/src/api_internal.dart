part of '../api.dart';

Response _latestResponse;

int _requestCount = 0;

Future _sendRequest(Client client, String method, String url,
    {Map<String, String> bodyFields,
    String bodyJson,
    Map<String, String> headers,
    bool parseJson}) async {
  _requestCount++;
  final request = Request(method, Uri.parse(url));
  if (headers != null) {
    request.headers.addAll(headers);
  }
  if (bodyFields != null) {
    request.bodyFields = bodyFields;
  } else if (bodyJson != null) {
    request.body = bodyJson;
    request.headers['Content-Type'] = 'application/json';
  }

  _latestResponse = await Response.fromStream(await client.send(request));

  print("$method $url -> ${_latestResponse.statusCode}");

  if (parseJson) {
    final decodedJson = json.decode(_latestResponse.body);
    _throwExceptionOnError(_latestResponse, decodedJson);
    return decodedJson;
  }

  return _latestResponse;
}

void _throwExceptionOnError(Response response, j) {
  if (response.statusCode < 400) {
    return;
  }

  if (j is Map) {
    if (j.containsKey('error_description')) {
      throw ApiError(message: j['error_description']);
    }
    if (j.containsKey('errors')) {
      final errors = List<String>.from(j['errors']);
      throw ApiError(messages: errors);
    }
  }

  throw ApiError();
}

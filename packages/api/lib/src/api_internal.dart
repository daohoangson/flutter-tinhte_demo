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

  if (parseJson) {
    _throwExceptionOnError(_latestResponse);
    return json.decode(_latestResponse.body);
  }

  return _latestResponse;
}

Response _throwExceptionOnError(Response response) {
  if (response.statusCode < 400) {
    return response;
  }

  Map j = json.decode(response.body);
  if (j.containsKey('error_description')) {
    throw ApiError(message: j['error_description']);
  }
  if (j.containsKey('errors')) {
    final errors = List<String>.from(j['errors']);
    throw ApiError(messages: errors);
  }

  throw ApiError();
}

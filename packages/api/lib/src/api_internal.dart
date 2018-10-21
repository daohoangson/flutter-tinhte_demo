part of '../api.dart';

Response _latestResponse;

int _requestCount = 0;

Future _sendRequest(Client client, String method, String url,
    {Map<String, String> bodyFields,
    String bodyJson,
    Map<String, File> fileFields,
    Map<String, String> headers,
    bool parseJson}) async {
  _requestCount++;
  final uri = Uri.parse(url);
  final request =
      fileFields == null ? Request(method, uri) : MultipartRequest(method, uri);

  if (headers != null) {
    request.headers.addAll(headers);
  }

  if (fileFields != null) {
    final mr = request as MultipartRequest;
    if (bodyFields != null) {
      mr.fields.addAll(bodyFields);
    }

    fileFields.forEach((field, file) => mr.files.add(MultipartFile(
          field,
          ByteStream(DelegatingStream.typed(file.openRead())),
          file.lengthSync(),
          filename: basename(file.path),
        )));
  } else if (bodyFields != null) {
    (request as Request).bodyFields = bodyFields;
  } else if (bodyJson != null) {
    (request as Request).body = bodyJson;
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

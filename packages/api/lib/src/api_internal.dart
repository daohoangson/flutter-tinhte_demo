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
          ByteStream(file.openRead().cast()),
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
    final error = _verifyResponseAndJsonForError(_latestResponse, decodedJson);
    return error ?? decodedJson;
  }

  return _latestResponse;
}

Future _verifyResponseAndJsonForError(Response response, j) {
  if (j is Map) {
    if (j.containsKey('error_description')) {
      return Future.error(ApiErrorSingle(j['error_description']));
    }
    if (j.containsKey('errors')) {
      if (j['errors'] is List) {
        final errors = List<String>.from(j['errors']);
        return Future.error(ApiErrors(errors));
      }

      if (j['errors'] is Map) {
        final errors = Map<String, String>.from(j['errors']);
        return Future.error(ApiErrorMapped(errors));
      }
    }
  }

  if (response.statusCode < 400) return null;
  return Future.error(ApiErrorUnexpectedStatusCode(response.statusCode));
}

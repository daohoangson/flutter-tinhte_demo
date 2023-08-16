import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:the_api_test/src/path.dart';

final mockedHttpClient = MockClient(_mockedHttpClientHandler);

Future<Response> _mockedHttpClientHandler(Request request) async {
  try {
    final body = await _mockGetRequest(request);

    return Response.bytes(
      utf8.encode(jsonEncode(body)),
      200,
      headers: {
        'content-type': 'application/json; charset=UTF-8',
      },
    );
  } catch (error, stackTrace) {
    debugPrint('error=$error stackTrace=$stackTrace');
    return Response('', 404);
  }
}

Future<Map> _mockGetRequest(Request request) async {
  final jsonPath = getFilePath(request.url, suffix: '.json');

  final file = File(jsonPath);
  if (!file.existsSync()) {
    throw StateError('$file does not exist for ${request.url}');
  }

  final cachedContents = file.readAsStringSync();
  final decoded = jsonDecode(cachedContents);
  return decoded['body'];
}

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:path/path.dart' as p;
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
  final parts = p
      .split(request.url.path)
      .where(
        (part) =>
            part.isNotEmpty &&
            part != '/' &&
            part != 'appforo' &&
            part != 'index.php',
      )
      .toList();
  final queryKeys = <String>[];
  final queryParameters = request.url.queryParameters;
  for (final key in queryParameters.keys) {
    if (key == 'oauth_token') continue;
    if (queryParameters[key] == '') {
      // take empty query as direct part
      parts.add(key);
    } else {
      queryKeys.add(key);
    }
  }

  // sort query keys before building path
  queryKeys.sort();
  for (final key in queryKeys) {
    parts.add('$key=${queryParameters[key]}');
  }

  final lastPart = parts.removeLast();
  final dirPath = p.joinAll([...mocksParts, ...cleanUpParts(parts)]);
  final jsonPath = p.join(dirPath, '$lastPart.json');

  final file = File(jsonPath);
  if (!file.existsSync()) {
    throw StateError('$file does not exist for ${request.url}');
  }

  final cachedContents = file.readAsStringSync();
  final decoded = jsonDecode(cachedContents);
  return decoded['body'];
}

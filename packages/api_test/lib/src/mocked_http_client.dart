import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:path/path.dart' as p;
import 'package:the_api/batch_job.dart';
import 'package:the_api_test/src/path.dart';

final mockedHttpClient = MockClient(_mockedHttpClientHandler);

Future<Response> _mockedHttpClientHandler(Request request) async {
  try {
    dynamic body;

    if (request.method == 'POST' &&
        request.url.queryParameters['batch'] == '') {
      body = await _mockBatchRequest(request);
    } else {
      body = await _mockRequest(
        path: request.url.path,
        params: request.url.queryParameters,
      );
    }

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

Future<Map> _mockRequest({
  required String path,
  required Map<String, String> params,
}) async {
  final parts = p
      .split(path)
      .where(
        (part) =>
            part.isNotEmpty &&
            part != '/' &&
            part != 'appforo' &&
            part != 'index.php',
      )
      .toList();
  final queryKeys = <String>[];
  for (final key in params.keys) {
    if (key == 'oauth_token') continue;
    if (params[key] == '') {
      // take empty query as direct part
      parts.add(key);
    } else {
      queryKeys.add(key);
    }
  }

  // sort query keys before building path
  queryKeys.sort();
  for (final key in queryKeys) {
    parts.add('$key=${params[key]}');
  }

  final lastPart = parts.removeLast();
  final dirPath = p.joinAll([...mocksParts, ...cleanUpParts(parts)]);
  final jsonPath = p.join(dirPath, '$lastPart.json');

  final file = File(jsonPath);
  if (!file.existsSync()) {
    throw StateError('$file does not exist');
  }

  final cachedContents = file.readAsStringSync();
  final decoded = jsonDecode(cachedContents);
  return decoded['body'];
}

Future<Map> _mockBatchRequest(Request request) async {
  final jobs = (jsonDecode(request.body) as List)
      .map((json) => BatchJob.fromJson(json))
      .toList(growable: false);

  final jobBodies = {};
  for (final job in jobs) {
    final uri = Uri.parse(job.uri);
    final jobBody = await _mockRequest(path: uri.path, params: {
      ...uri.queryParameters,
      ...(job.params ?? const {}),
    });
    jobBodies[job.id] = {
      "_job_result": "ok",
      ...jobBody,
    };
  }

  return {"jobs": jobBodies};
}

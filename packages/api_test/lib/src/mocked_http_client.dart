import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:the_api_test/src/path.dart';

final mockedHttpClient = MockClient(_mockedHttpClientHandler);

Future<Response> _mockedHttpClientHandler(Request request) async {
  try {
    final body = await _mockGetRequest(request);

    return Response.bytes(
      body,
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

Future<List<int>> _mockGetRequest(Request request) async {
  final jsonPath = getFilePath(request.url, suffix: '.json');
  final jsonFile = File(jsonPath);
  if (jsonFile.existsSync()) {
    return jsonFile.readAsBytesSync();
  }

  final zipPath = '$jsonPath.zip';
  final zipFile = File(zipPath);
  if (!zipFile.existsSync()) {
    throw StateError('$zipFile does not exist for ${request.url}');
  }

  final inputStream = InputFileStream(zipPath);
  final archive = ZipDecoder().decodeBuffer(inputStream);
  for (var file in archive.files) {
    return file.content;
  }

  throw StateError('$zipPath does not contain any file');
}

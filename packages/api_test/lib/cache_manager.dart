import 'dart:io';
import 'dart:typed_data';

import 'package:file/file.dart' as file;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:the_api_test/src/path.dart';

class MockedCacheManager extends Mock implements BaseCacheManager {
  @override
  Stream<FileResponse> getFileStream(
    String url, {
    String? key,
    Map<String, String>? headers,
    bool? withProgress,
  }) async* {
    final file = _MockedCacheManagerFile();
    when(() => file.readAsBytes()).thenAnswer((_) async {
      final uri = Uri.parse(url);
      final parts = p.split(uri.path).where((part) => part != '/');
      final filePath = p.joinAll([...mocksParts, ...cleanUpParts(parts)]);
      final file = File(filePath);
      if (file.existsSync()) {
        return file.readAsBytesSync();
      } else {
        throw StateError('$file does not exist for $url');
      }
    });

    yield FileInfo(
      file,
      FileSource.Online,
      DateTime.now().add(const Duration(days: 1)),
      url,
    );
  }
}

class _MockedCacheManagerFile extends Mock implements file.File {}

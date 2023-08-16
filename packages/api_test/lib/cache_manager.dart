import 'dart:io';

import 'package:file/file.dart' as file;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:mocktail/mocktail.dart';
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
      final filePath = getFilePath(Uri.parse(url));
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

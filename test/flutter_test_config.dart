import 'dart:async';
import 'dart:io';

import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:the_api_test/cache_manager.dart';
import 'package:the_app/src/abstracts/cached_network_image.dart'
    as cached_network_image;
import 'package:the_app/src/abstracts/progress_indicator.dart'
    as progress_indicator;

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  return GoldenToolkit.runWithConfiguration(
    () async {
      cached_network_image.debugCacheManager = MockedCacheManager();
      progress_indicator.debugDeterministic = true;

      await testMain();
    },
    config: GoldenToolkitConfiguration(
      // golden tests should only execute on macOS
      skipGoldenAssertion: () => !Platform.isMacOS,
    ),
  );
}

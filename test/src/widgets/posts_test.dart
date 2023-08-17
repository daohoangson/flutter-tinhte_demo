import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../../test_utils.dart';

void main() {
  group('PostsWidget', () {
    testGoldens('renders short thread', (tester) async {
      await tester.pumpMockedApiApp(
        const ThreadViewTestApp(threadId: 3704815),
        surfaceSize: const Size(800, 5000),
      );
      await tester.waitForStuff();

      await screenMatchesGolden(tester, 'posts/thread_3704815');
    });

    testGoldens('renders long thread', (tester) async {
      await tester.pumpMockedApiApp(
        const ThreadViewTestApp(threadId: 3704463),
        surfaceSize: const Size(800, 5000),
      );
      await tester.waitForStuff();
      await screenMatchesGolden(tester, 'posts/thread_3704463');

      await tester.tap(find.text('Tap to load 7 hidden replies...'));
      await tester.waitForStuff();
      await screenMatchesGolden(tester, 'posts/thread_3704463_with_hidden');
    });

    testGoldens('renders poll', (tester) async {
      await tester.pumpMockedApiApp(
        const ThreadViewTestApp(threadId: 3441248),
        surfaceSize: const Size(800, 5000),
      );
      await tester.waitForStuff();

      await screenMatchesGolden(tester, 'posts/thread_3441248');
    });
  });
}

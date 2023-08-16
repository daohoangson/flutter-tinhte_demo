import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:the_app/src/intl.dart';

import '../../test_utils.dart';

void main() {
  debugClock = DateTime(2023, 8, 16);

  group('PostsWidget', () {
    testGoldens('renders short thread', (tester) async {
      await tester.pumpMockedApiApp(
        const ThreadViewTestApp(threadId: 3704815),
        surfaceSize: const Size(800, 5000),
      );
      await tester.waitForStuff();

      await screenMatchesGolden(tester, 'posts/thread_3704815');
    });
  });
}

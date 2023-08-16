import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../../test_utils.dart';

void main() {
  group('TinhteHtmlWidget', () {
    testGoldens('renders galleria', (tester) async {
      await tester.pumpMockedApiApp(
        const ThreadViewTestApp(threadId: 3703386),
        surfaceSize: const Size(800, 6000),
      );
      await tester.waitForStuff();

      await screenMatchesGolden(tester, 'html/galleria');
    });
  });
}

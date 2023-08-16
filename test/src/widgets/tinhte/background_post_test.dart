import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../../../test_utils.dart';

void main() {
  group('BackgroundPost', () {
    testGoldens('renders', (tester) async {
      await tester.pumpMockedApiApp(
        const ThreadViewTestApp(threadId: 3072651),
      );
      await tester.waitForStuff();

      await screenMatchesGolden(tester, 'background_post');
    });
  });
}

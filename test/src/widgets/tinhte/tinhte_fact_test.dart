import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../../../test_utils.dart';

void main() {
  group('TinhteFact', () {
    testGoldens('renders', (tester) async {
      await tester.pumpMockedApiApp(
        const ThreadViewTestApp(threadId: 3704680),
      );
      await tester.waitForStuff();

      await screenMatchesGolden(tester, 'tinhte_fact');
    });
  });
}

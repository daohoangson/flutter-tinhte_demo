import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:the_app/src/screens/forum_list.dart';

import '../../test_utils.dart';

void main() {
  group('NavigationWidget', () {
    testGoldens('renders forum list', (tester) async {
      await tester.pumpMockedApiApp(const ForumListScreen());
      await tester.waitForStuff();

      await screenMatchesGolden(tester, 'navigation/parent-0');
    });

    testGoldens('handles category tap', (tester) async {
      await tester.pumpMockedApiApp(const ForumListScreen());
      await tester.waitForStuff();

      await tester.tap(find.text('Thông tin - Sự kiện'));
      await tester.waitForStuff();

      await screenMatchesGolden(tester, 'navigation/parent-619');
    });

    testGoldens('handles forum tap', (tester) async {
      await tester.pumpMockedApiApp(const ForumListScreen());
      await tester.waitForStuff();

      await tester.tap(find.text('Máy bay'));
      await tester.waitForStuff();

      await screenMatchesGolden(tester, 'navigation/parent-762');
    });
  });
}

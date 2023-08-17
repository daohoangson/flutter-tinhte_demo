import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:the_app/src/widgets/html.dart';

import '../../test_utils.dart';

void main() {
  group('TinhteHtmlWidget', () {
    testGoldens('renders galleria', (tester) async {
      await tester.pumpMockedApiApp(
        const ThreadViewTestApp(threadId: 3703386),
        surfaceSize: const Size(800, 2000),
      );
      await tester.waitForStuff();

      await screenMatchesGolden(tester, 'html/galleria');
    });

    testGoldens('renders compare', (tester) async {
      await tester.pumpMockedApiApp(
        const ThreadViewTestApp(threadId: 3682335),
        surfaceSize: const Size(800, 2000),
      );
      await tester.waitForStuff();

      await screenMatchesGolden(tester, 'html/compare');
    });

    testGoldens('renders YouTube', (tester) async {
      await tester.pumpMockedApiApp(
        const Column(
          children: [
            YouTubeWidget(
              'dQw4w9WgXcQ',
              lowresThumbnailUrl:
                  'https://img.youtube.com/vi/dQw4w9WgXcQ/0.jpg',
            ),
          ],
        ),
        surfaceSize: const Size(800, 2000),
      );
      await tester.waitForStuff();

      await screenMatchesGolden(tester, 'html/youtube');
    });
  });
}

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:the_app/src/widgets/menu/dev_tools.dart';
import 'package:the_app/src/widgets/menu/package_info.dart';

import '../../../test_utils.dart';

void main() {
  group('PackageInfoWidget', () {
    const version = '1.0.0';
    const buildNumber = '2';

    setUp(() {
      PackageInfo.setMockInitialValues(
        appName: 'appName',
        packageName: 'packageName',
        version: version,
        buildNumber: buildNumber,
        buildSignature: "buildSignature",
      );
    });

    testWidgets('show about dialog on tap', (tester) async {
      final devTools = _MockedDevTools();
      await tester.pumpMockedApiApp(
        ChangeNotifierProvider<DevTools>.value(
          value: devTools,
          child: const PackageInfoWidget(),
        ),
      );

      await tester.tap(find.text('Version'));
      await tester.pumpAndSettle();

      expect(devTools.isDeveloper, isFalse);
      final target = find.text('$version (build number: $buildNumber)');
      await tester.tap(target);
      await tester.pumpAndSettle();
      expect(devTools.isDeveloper, isFalse);

      await tester.tap(target);
      await tester.pumpAndSettle();
      expect(devTools.isDeveloper, isFalse);

      // third tap enables developer mode
      await tester.tap(target);
      await tester.pumpAndSettle();
      expect(devTools.isDeveloper, isTrue);

      // the next one disables it again
      await tester.tap(target);
      await tester.pumpAndSettle();
      expect(devTools.isDeveloper, isFalse);
    });
  });
}

class _MockedDevTools extends ChangeNotifier implements DevTools {
  @override
  var isDeveloper = false;

  @override
  var showPerformanceOverlay = false;
}

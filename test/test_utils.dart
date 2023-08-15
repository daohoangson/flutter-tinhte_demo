import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:the_api_test/provider.dart';
import 'package:the_app/src/api.dart';
import 'package:the_app/src/intl.dart';

class MockedApiApp extends StatelessWidget {
  final Widget child;

  const MockedApiApp({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return MockedHttpClientProvider(
      child: ApiApp(
        enableBatch: false,
        child: child,
      ),
    );
  }
}

final builtInWrapper = materialAppWrapper(
  localizations: const [L10nDelegate()],
);

extension ApiAppTester on WidgetTester {
  Future<void> pumpMockedApiApp(Widget widget) async {
    await pumpWidgetBuilder(
      widget,
      wrapper: (widget) {
        final built = builtInWrapper(widget);
        return MockedApiApp(child: built);
      },
    );
  }

  Future<void> waitForStuff() async {
    await runAsync(() => Future.delayed(const Duration(milliseconds: 10)));
    await pumpAndSettle();
  }
}

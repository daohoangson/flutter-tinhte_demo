import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:provider/provider.dart';
import 'package:the_api/thread.dart';
import 'package:the_api_test/provider.dart';
import 'package:the_app/src/abstracts/progress_indicator.dart';
import 'package:the_app/src/api.dart';
import 'package:the_app/src/intl.dart';
import 'package:the_app/src/widgets/font_control.dart';
import 'package:the_app/src/widgets/posts.dart';

class MockedApiApp extends StatelessWidget {
  final Widget child;

  const MockedApiApp({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<FontScale>(create: (_) => _MockedFontScale()),
      ],
      child: MockedHttpClientProvider(
        child: ApiApp(
          enableBatch: false,
          child: child,
        ),
      ),
    );
  }
}

final builtInWrapper = materialAppWrapper(
  localizations: const [L10nDelegate()],
);

extension ApiAppTester on WidgetTester {
  Future<void> pumpMockedApiApp(
    Widget widget, {
    Size surfaceSize = const Size(800, 600),
  }) async {
    await pumpWidgetBuilder(
      widget,
      surfaceSize: surfaceSize,
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

class ThreadViewTestApp extends StatefulWidget {
  final int threadId;

  const ThreadViewTestApp({Key? key, required this.threadId}) : super(key: key);

  @override
  State<ThreadViewTestApp> createState() => _ThreadViewTestAppState();
}

class _ThreadViewTestAppState extends State<ThreadViewTestApp> {
  final completer = Completer<Thread>();
  Map? initialJson;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    apiGet(
      ApiCaller.stateful(this),
      'posts&thread_id=${widget.threadId}',
      onSuccess: (json) {
        initialJson = json;

        for (final postJson in (json['posts'] as List)) {
          final threadJson = json['thread'] as Map<String, dynamic>;
          threadJson['firstPost'] = postJson;
          final thread = Thread.fromJson(threadJson);
          completer.complete(thread);
          return;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: FutureBuilder(
          builder: (context, snapshot) {
            final thread = snapshot.data;
            if (thread == null) return const AdaptiveProgressIndicator();
            return PostsWidget(thread, initialJson: initialJson);
          },
          future: completer.future,
        ),
      );
}

class _MockedFontScale extends ChangeNotifier implements FontScale {
  @override
  var value = 1.0;
}

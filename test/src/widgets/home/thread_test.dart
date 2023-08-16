import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:the_api/search.dart';
import 'package:the_api/thread.dart';
import 'package:the_api/x_content_list.dart';
import 'package:the_app/src/widgets/home/thread.dart';
import 'package:the_app/src/widgets/super_list.dart';

import '../../../test_utils.dart';

void main() {
  group('HomeThreadWidget', () {
    testGoldens('renders', (tester) async {
      await tester.pumpMockedApiApp(const _HomeThreadTestApp());
      await tester.waitForStuff();

      await screenMatchesGolden(tester, 'thread');
    });
  });
}

class _HomeThreadTestApp extends StatelessWidget {
  const _HomeThreadTestApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SuperListView<SearchResult<Thread>>(
          fetchPathInitial: 'lists/1/threads',
          fetchOnSuccess: _fetchOnSuccess,
          itemBuilder: (_, __, srt) => HomeThreadWidget(srt),
        ),
      );

  void _fetchOnSuccess(Map json, FetchContext<SearchResult<Thread>> fc) {
    for (final threadJson in (json['threads'] as List)) {
      final thread = Thread.fromJson(threadJson);
      final srt = SearchResult<Thread>(
        'thread',
        thread.threadId,
        content: thread,
        listItem: ContentListItem.fromJson(threadJson['list_item']),
      );
      fc.items.add(srt);
    }
  }
}

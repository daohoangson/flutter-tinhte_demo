import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:the_api/search.dart';
import 'package:the_api/thread.dart';
import 'package:the_app/src/widgets/home/top_5.dart';
import 'package:the_app/src/widgets/super_list.dart';

import '../../../test_utils.dart';

void main() {
  group('HomeTop5Widget', () {
    testGoldens('renders', (tester) async {
      await tester.pumpMockedApiApp(const _HomeTop5TestApp());
      await tester.waitForStuff();

      await screenMatchesGolden(tester, 'top_5');
    });
  });
}

typedef _Top5 = List<SearchResult<Thread>>;

class _HomeTop5TestApp extends StatelessWidget {
  const _HomeTop5TestApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SuperListView<_Top5>(
          fetchPathInitial: 'lists/1/threads',
          fetchOnSuccess: _fetchOnSuccess,
          itemBuilder: (_, __, top5) =>
              SuperListItemFullWidth(child: HomeTop5Widget(top5)),
        ),
      );

  void _fetchOnSuccess(Map json, FetchContext<_Top5> fc) {
    final threadsJson = json['threads'] as List;
    final _Top5 top5 = [];
    for (final threadJson in threadsJson) {
      final thread = Thread.fromJson(threadJson);
      final result =
          SearchResult<Thread>('thread', thread.threadId, content: thread);
      if (top5.length < 5) {
        top5.add(result);
      }
      if (top5.length == 5) {
        fc.items.add(top5);
        return;
      }
    }
  }
}

import 'package:flutter/material.dart';
import 'package:tinhte_api/search.dart';
import 'package:tinhte_api/thread.dart';
import 'package:tinhte_demo/src/constants.dart';
import 'package:tinhte_demo/src/widgets/home/thread.dart';
import 'package:tinhte_demo/src/widgets/super_list.dart';

class ContentListViewScreen extends StatelessWidget {
  final int listId;
  final String title;

  ContentListViewScreen({
    Key key,
    @required this.listId,
    @required this.title,
  })  : assert(listId != null),
        assert(title != null),
        super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: SuperListView<SearchResult<Thread>>(
          fetchPathInitial: "lists/$listId/threads?limit=20"
              '&_bdImageApiThreadThumbnailWidth=${(kThreadThumbnailWidth * 3).toInt()}'
              '&_bdImageApiThreadThumbnailHeight=sh',
          fetchOnSuccess: _fetchOnSuccess,
          itemBuilder: (_, __, thread) => HomeThreadWidget(thread),
        ),
      );

  void _fetchOnSuccess(Map json, FetchContext<SearchResult<Thread>> fc) {
    if (!json.containsKey('threads')) return;

    final list = json['threads'] as List;
    fc.items.addAll(list.map((j) => SearchResult<Thread>.fromJson(j)));
  }
}

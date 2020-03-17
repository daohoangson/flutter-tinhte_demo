import 'package:flutter/material.dart';
import 'package:tinhte_api/content_list.dart';
import 'package:tinhte_demo/src/widgets/home/thread.dart';
import 'package:tinhte_demo/src/widgets/super_list.dart';

const kContentListViewThumbnailWidth = 200.0;

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
        body: SuperListView<ThreadListItem>(
          fetchPathInitial: "lists/$listId/threads?limit=20"
              '&_bdImageApiThreadThumbnailWidth=${(kContentListViewThumbnailWidth * 3).toInt()}'
              '&_bdImageApiThreadThumbnailHeight=sh',
          fetchOnSuccess: _fetchOnSuccess,
          itemBuilder: (_, __, thread) => HomeThreadWidget(
            thread,
            imageWidth: kContentListViewThumbnailWidth,
          ),
        ),
      );

  void _fetchOnSuccess(Map json, FetchContext<ThreadListItem> fc) {
    if (!json.containsKey('threads')) return;

    final list = json['threads'] as List;
    fc.items.addAll(list.map((j) => ThreadListItem.fromJson(j)));
  }
}

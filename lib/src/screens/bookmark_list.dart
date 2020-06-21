import 'package:flutter/material.dart';
import 'package:tinhte_demo/src/intl.dart';
import 'package:tinhte_demo/src/widgets/threads.dart';
import 'package:tinhte_demo/src/config.dart';

class BookmarkListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(l(context).threadBookmarkList),
        ),
        body: ThreadsWidget(
          path: config.apiBookmarkPath,
          threadsKey: 'items',
        ),
      );
}

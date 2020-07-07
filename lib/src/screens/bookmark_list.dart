import 'package:flutter/material.dart';
import 'package:the_app/src/intl.dart';
import 'package:the_app/src/widgets/threads.dart';
import 'package:the_app/src/config.dart';

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

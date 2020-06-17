import 'package:flutter/material.dart';
import 'package:tinhte_api/node.dart';
import 'package:tinhte_demo/src/intl.dart';
import 'package:tinhte_demo/src/screens/search/thread.dart';
import 'package:tinhte_demo/src/widgets/navigation.dart';
import 'package:tinhte_demo/src/widgets/threads.dart';

class ForumViewScreen extends StatefulWidget {
  final Forum forum;

  ForumViewScreen(this.forum, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ForumViewScreenState();
}

class _ForumViewScreenState extends State<ForumViewScreen> {
  var _fabIsVisible = true;

  Forum get forum => widget.forum;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(forum.forumTitle),
        ),
        body: NotificationListener<ScrollNotification>(
          child: ThreadsWidget(
            forum: forum,
            header: NavigationWidget(
              path: "navigation?parent=${forum.forumId}",
              progressIndicator: false,
              shrinkWrap: true,
            ),
            path: "threads?forum_id=${forum.forumId}",
          ),
          onNotification: (scrollInfo) {
            if (scrollInfo is ScrollUpdateNotification) {
              setState(() => _fabIsVisible = scrollInfo.scrollDelta < 0.0);
            }
            return false;
          },
        ),
        floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
        floatingActionButton: _fabIsVisible
            ? FloatingActionButton(
                child: Icon(Icons.search),
                onPressed: () => showSearch(
                  context: context,
                  delegate: ThreadSearchDelegate(forum: forum),
                ),
                tooltip: l(context).searchThisForum,
              )
            : null,
      );
}

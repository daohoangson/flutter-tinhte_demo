import 'package:flutter/material.dart';
import 'package:tinhte_api/node.dart';

import '../widgets/navigation.dart';
import '../widgets/threads.dart';

class ForumViewScreen extends StatelessWidget {
  final Forum forum;

  ForumViewScreen(this.forum, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(forum.forumTitle),
        ),
        body: ThreadsWidget(
          forum: forum,
          header: NavigationWidget(
            path: "navigation?parent=${forum.forumId}",
            shrinkWrap: true,
          ),
          path: "threads?forum_id=${forum.forumId}",
        ),
      );
}

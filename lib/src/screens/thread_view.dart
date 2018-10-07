import 'package:flutter/material.dart';

import 'package:tinhte_demo/api/model/thread.dart';
import '../widgets/posts.dart';

class ThreadViewScreen extends StatelessWidget {
  final Thread thread;

  ThreadViewScreen({Key key, this.thread}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(thread.threadTitle),
      ),
      body: PostsWidget(
        path: "posts?thread_id=${thread.threadId}",
        thread: thread,
      ),
    );
  }
}

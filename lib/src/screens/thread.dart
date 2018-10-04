import 'package:flutter/material.dart';

import 'package:tinhte_demo/api/model/thread.dart';
import '../widgets/posts.dart';

class ThreadScreen extends StatefulWidget {
  final Thread thread;

  ThreadScreen({Key key, this.thread}) : super(key: key);

  @override
  _ThreadScreenState createState() => new _ThreadScreenState();
}

class _ThreadScreenState extends State<ThreadScreen> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.thread.threadTitle),
      ),
      body: new Center(
          child: new PostsWidget("posts?thread_id=${widget.thread.threadId}&limit=3"),
      ),
    );
  }
}

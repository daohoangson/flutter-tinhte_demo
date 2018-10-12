import 'package:flutter/material.dart';

import 'package:tinhte_demo/api/model/thread.dart';
import 'package:tinhte_demo/api/model/links.dart';
import '../screens/thread_view.dart';
import 'api.dart';
import 'thread_image.dart';

class ThreadsWidget extends StatefulWidget {
  final String path;
  final List<Thread> _threads;

  ThreadsWidget({
    Key key,
    this.path,
    List<Thread> threads,
  })  : _threads = threads ?? List(),
        super(key: key);

  @override
  _ThreadsWidgetState createState() => _ThreadsWidgetState(this.path);
}

class _ThreadsWidgetState extends State<ThreadsWidget> {
  bool isFetching = false;
  final scrollController = ScrollController();
  String url;

  _ThreadsWidgetState(this.url);

  @override
  void initState() {
    super.initState();

    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        fetch();
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget._threads.length == 0) fetch();

    return ListView.builder(
      controller: scrollController,
      itemBuilder: (context, i) {
        if (i == widget._threads.length) {
          return _buildProgressIndicator();
        }
        return _buildRow(widget._threads[i]);
      },
      itemCount: widget._threads.length + 1,
    );
  }

  void fetch() async {
    if (isFetching || url == null) {
      return;
    }
    setState(() => isFetching = true);

    List<Thread> newThreads = List();
    String nextUrl;

    final api = ApiInheritedWidget.of(context).api;
    final json = await api.getJson(url);
    final jsonMap = json as Map<String, dynamic>;
    if (jsonMap.containsKey('threads')) {
      final jsonThreads = json['threads'] as List<dynamic>;
      jsonThreads
          .forEach((jsonThread) => newThreads.add(Thread.fromJson(jsonThread)));
    }

    if (jsonMap.containsKey('links')) {
      final links = Links.fromJson(json['links']);
      nextUrl = links.next;
    }

    setState(() {
      isFetching = false;
      widget._threads.addAll(newThreads);
      url = nextUrl;
    });
  }

  Widget _buildProgressIndicator() => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Opacity(
            opacity: isFetching ? 1.0 : 0.0,
            child: CircularProgressIndicator(),
          ),
        ),
      );

  Widget _buildRow(Thread thread) {
    final List<Widget> children = List();

    if (thread.threadImage != null) {
      children.add(ThreadImageWidget(image: thread.threadImage));
    }

    children.addAll(<Widget>[
      Padding(
        padding: const EdgeInsets.all(5.0),
        child: Text(
          thread.threadTitle,
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(5.0),
        child: Text(
          thread.firstPost.postBodyPlainText,
          maxLines: 5,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ]);

    return GestureDetector(
      child: Card(
        child: Column(
          children: children,
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
      ),
      onTap: () => pushThreadViewScreen(context, thread),
    );
  }
}

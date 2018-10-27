import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:tinhte_api/links.dart';
import 'package:tinhte_api/thread.dart';

import '../screens/thread_view.dart';
import '../api.dart';
import '../intl.dart';
import '_list_view.dart';
import 'image.dart';

part 'thread/builders.dart';

class ThreadsWidget extends StatefulWidget {
  final String path;
  final String threadsKey;

  ThreadsWidget(
    this.path, {
    Key key,
    this.threadsKey = 'threads',
  }) : super(key: key);

  @override
  _ThreadsWidgetState createState() => _ThreadsWidgetState(this.path);
}

class _ThreadsWidgetState extends State<ThreadsWidget> {
  final scrollController = ScrollController();
  final List<Thread> threads = List();

  bool _isFetching = false;
  String _url;

  String get threadsKey => widget.threadsKey;

  _ThreadsWidgetState(this._url);

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (threads.length == 0) fetch();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListView.builder(
        controller: scrollController,
        itemBuilder: (context, i) => i >= threads.length
            ? buildProgressIndicator(_isFetching)
            : buildThreadRow(context, threads[i]),
        itemCount: threads.length + 1,
      );

  fetch() {
    if (_isFetching || _url == null) return;
    setState(() => _isFetching = true);

    apiGet(this, _url,
        onSuccess: (jsonMap) {
          final List<Thread> newThreads = List();
          String nextUrl;

          if (jsonMap.containsKey(threadsKey)) {
            final jsonThreads = jsonMap[threadsKey] as List;
            jsonThreads.forEach((j) => newThreads.add(Thread.fromJson(j)));
          }

          if (jsonMap.containsKey('links')) {
            final links = Links.fromJson(jsonMap['links']);
            nextUrl = links.next;
          }

          setState(() {
            threads.addAll(newThreads);
            _url = nextUrl;
          });
        },
        onComplete: () => setState(() => _isFetching = false));
  }
}

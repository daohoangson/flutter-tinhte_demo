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
  final Widget header;
  final Map<dynamic, dynamic> initialJson;
  final String path;
  final String threadsKey;

  ThreadsWidget({
    this.header,
    this.initialJson,
    Key key,
    this.path,
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
  int get itemCount =>
      (widget.header != null ? 1 : 0) + threads.length + (_isFetching ? 1 : 0);

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
        itemBuilder: (context, i) {
          if (widget.header != null) {
            if (i == 0) return widget.header;
            i--;
          }

          if (i >= threads.length) {
            return buildProgressIndicator(true);
          }

          return buildThreadRow(context, threads[i]);
        },
        itemCount: itemCount,
      );

  void fetch() {
    if (_isFetching || _url == null) return;
    setState(() => _isFetching = true);

    return apiGet(
      this,
      _url,
      onSuccess: fetchOnSuccess,
      onComplete: () => setState(() => _isFetching = false),
    );
  }

  void fetchOnSuccess(Map<dynamic, dynamic> json) {
    final List<Thread> newThreads = List();
    String nextUrl;

    if (json.containsKey(threadsKey)) {
      final jsonThreads = json[threadsKey] as List;
      jsonThreads.forEach((j) {
        final thread = Thread.fromJson(j);
        if (thread.threadId == null || thread.firstPost == null) return;

        newThreads.add(thread);
      });
    }

    if (json.containsKey('links')) {
      final links = Links.fromJson(json['links']);
      nextUrl = links.next;
    }

    setState(() {
      threads.addAll(newThreads);
      _url = nextUrl;
    });
  }
}

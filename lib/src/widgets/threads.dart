import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:tinhte_api/links.dart';
import 'package:tinhte_api/thread.dart';

import '../screens/thread_view.dart';
import '../intl.dart';
import '_list_view.dart';
import '_api.dart';
import 'image.dart';

part 'thread/builders.dart';

class ThreadsWidget extends StatefulWidget {
  final String path;

  ThreadsWidget({Key key, this.path}) : super(key: key);

  @override
  _ThreadsWidgetState createState() => _ThreadsWidgetState(this.path);
}

class _ThreadsWidgetState extends State<ThreadsWidget> {
  final scrollController = ScrollController();
  final List<Thread> threads = List();

  bool _isFetching = false;
  String _url;

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
          if (i == threads.length) {
            return buildProgressIndicator(_isFetching);
          }
          return buildThreadRow(context, threads[i]);
        },
        itemCount: threads.length + 1,
      );

  void fetch() async {
    if (_isFetching || _url == null) return;
    setState(() => _isFetching = true);

    List<Thread> newThreads = List();
    String nextUrl;

    final api = ApiInheritedWidget.of(context).api;
    final json = await api.getJson(_url);
    final jsonMap = json as Map<String, dynamic>;
    if (jsonMap.containsKey('threads')) {
      final jsonThreads = json['threads'] as List<dynamic>;
      jsonThreads.forEach((j) => newThreads.add(Thread.fromJson(j)));
    }

    if (jsonMap.containsKey('links')) {
      final links = Links.fromJson(json['links']);
      nextUrl = links.next;
    }

    setState(() {
      _isFetching = false;
      threads.addAll(newThreads);
      _url = nextUrl;
    });
  }
}

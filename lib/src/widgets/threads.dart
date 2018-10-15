import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:tinhte_api/links.dart';
import 'package:tinhte_api/thread.dart';

import '../screens/thread_view.dart';
import '_list_view.dart';
import '_api.dart';
import 'thread_image.dart';

Widget buildThreadRow(BuildContext context, Thread thread) {
  final postBodyAndMetadata = Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Padding(
        padding: const EdgeInsets.all(5.0),
        child: Text(
          thread.firstPost.postBodyPlainText,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 5.0),
        child: RichText(
          text: buildThreadTextSpan(context, thread),
        ),
      ),
    ],
  );

  final bodyAndPossiblyImage = thread.threadImage != null
      ? Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: MediaQuery.of(context).size.width * .4,
              child: ThreadImageWidget(image: thread?.threadImage),
            ),
            Expanded(child: postBodyAndMetadata),
          ],
        )
      : postBodyAndMetadata;

  return GestureDetector(
    child: Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Text(
              thread.threadTitle,
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
          ),
          bodyAndPossiblyImage,
        ],
      ),
    ),
    onTap: () => pushThreadViewScreen(context, thread),
  );
}

TextSpan buildThreadTextSpan(BuildContext context, Thread thread) {
  List<TextSpan> spans = List();

  spans.add(TextSpan(
    style: TextStyle(
      color: Theme.of(context).accentColor,
      fontWeight: FontWeight.bold,
    ),
    text: thread?.creatorUsername ?? '',
  ));

  spans.addAll(<TextSpan>[
    TextSpan(text: ' • '),
    TextSpan(
      style: TextStyle(
        color: Theme.of(context).disabledColor,
      ),
      text: thread != null
          ? timeago.format(DateTime.fromMillisecondsSinceEpoch(
              thread.threadCreateDate * 1000))
          : '',
    ),
  ]);

  if (thread?.threadIsSticky == true) {
    spans.add(TextSpan(text: '  📌'));
  }

  if (thread?.threadIsFollowed == true) {
    spans.add(TextSpan(text: '  👁'));
  }

  return TextSpan(
    children: spans,
    style: TextStyle(
      fontSize: 12.0,
    ),
  );
}

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
          return buildProgressIndicator(isFetching);
        }
        return buildThreadRow(context, widget._threads[i]);
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
}

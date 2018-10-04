import 'package:flutter/material.dart';

import 'package:tinhte_demo/api/model/thread.dart';
import 'package:tinhte_demo/api/model/links.dart';
import 'api.dart';
import '../screens/thread.dart';

class ThreadsWidget extends StatefulWidget {
  final String path;

  ThreadsWidget(this.path);

  @override
  _ThreadsWidgetState createState() => _ThreadsWidgetState(this.path);
}

class _ThreadsWidgetState extends State<ThreadsWidget> {
  bool isFetching = false;
  final scrollController = new ScrollController();
  final List<Thread> threads = new List();
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
    if (threads.length == 0) {
      fetch();
    }

    return new ListView.builder(
      controller: scrollController,
      itemBuilder: (context, i) {
        if (i == threads.length) {
          return _buildProgressIndicator();
        }
        return _buildRow(threads[i]);
      },
      itemCount: threads.length + 1,
    );
  }

  void fetch() async {
    if (isFetching || url == null) {
      return;
    }
    setState(() => isFetching = true);
    
    List<Thread> newThreads = new List();
    String newUrl;

    final api = ApiInheritedWidget.of(context).api;
    final json = await api.getJson(url);
    final jsonMap = json as Map<String, dynamic>;
    if (jsonMap.containsKey('threads')) {
      final jsonThreads = json['threads'] as List<dynamic>;
      jsonThreads.forEach((jsonThread) => threads.add(Thread.fromJson(jsonThread)));
    }

    if (jsonMap.containsKey('links')) {
      final links = Links.fromJson(json['links']);
      newUrl = links.next;
    }

    setState(() {
      isFetching = false;
      threads.addAll(newThreads);
      url = newUrl;
    });
  }

  Widget _buildProgressIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: new Opacity(
          opacity: isFetching ? 1.0 : 0.0,
          child: new CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildRow(Thread thread) {
    return new Card(
      child: new Column(
        children: <Widget>[
          thread.threadImage != null ? AspectRatio(
            aspectRatio: 16/9,
            child: new Image.network(
              thread.threadImage.link,
              fit: BoxFit.cover,
            ),
          ) : null,
          new ListTile(
            title: new Text(
              thread.threadTitle,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: new Text(
              thread.firstPost.postBodyPlainText,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => 
              Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ThreadScreen(thread: thread)),
            ),
          ),
          new ButtonTheme.bar(
            child: new ButtonBar(
              children: <Widget>[
                new FlatButton(
                  child: const Text('LIKE'),
                  onPressed: () { /* ... */ },
                ),
                new FlatButton(
                  child: const Text('COMMENT'),
                  onPressed: () { /* ... */ },
                ),
                new FlatButton(
                  child: const Text('SHARE'),
                  onPressed: () { /* ... */ },
                ),
              ],
            ),
          ),
        ],
        mainAxisSize: MainAxisSize.min,
      ),
    );
  }
}
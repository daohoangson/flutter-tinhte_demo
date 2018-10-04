import 'package:cached_network_image/cached_network_image.dart';
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
  final scrollController = ScrollController();
  final List<Thread> threads = List();
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

    return ListView.builder(
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
    
    List<Thread> newThreads = List();
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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Opacity(
          opacity: isFetching ? 1.0 : 0.0,
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildRow(Thread thread) {
    if (thread.threadImage != null) {
      return _buildRowWithImage(thread);
    } else {
      return _buildRowWithoutImage(thread);
    }
  }

  Widget _buildRowButtons(Thread thread) {
    return ButtonTheme.bar(
      child: ButtonBar(
        children: <Widget>[
          FlatButton(
            child: const Text('LIKE'),
            onPressed: () { /* ... */ },
          ),
          FlatButton(
            child: const Text('COMMENT'),
            onPressed: () { /* ... */ },
          ),
          FlatButton(
            child: const Text('SHARE'),
            onPressed: () { /* ... */ },
          ),
        ],
      ),
    );
  }

  Widget _buildRowListTile(Thread thread) {
    return ListTile(
      title: Text(
        thread.threadTitle,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        thread.firstPost.postBodyPlainText,
        maxLines: 5,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () => 
        Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ThreadScreen(thread: thread)),
      ),
    );
  }

  Widget _buildRowWithImage(Thread thread) {
    return Card(
      child: Column(
        children: <Widget>[
          AspectRatio(
            aspectRatio: 594/368,
            child: CachedNetworkImage(
              imageUrl: thread.threadImage.link,
              fit: BoxFit.cover,
            ),
          ),
          _buildRowListTile(thread),
          _buildRowButtons(thread),
        ],
        mainAxisSize: MainAxisSize.min,
      ),
    );
  }

  Widget _buildRowWithoutImage(Thread thread) {
    return Card(
      child: Column(
        children: <Widget>[
          _buildRowListTile(thread),
          _buildRowButtons(thread),
        ],
        mainAxisSize: MainAxisSize.min,
      ),
    );
  }
}
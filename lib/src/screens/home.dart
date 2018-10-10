import 'package:flutter/material.dart';

import 'package:tinhte_demo/api/model/thread.dart';
import '../widgets/api.dart';
import '../widgets/navigation.dart';
import 'home/threads_top_five.dart';

class HomeScreen extends StatefulWidget {
  final String title;

  HomeScreen({Key key, this.title}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isFetching = false;
  final List<Thread> threadsTopFive = List();
  final List<Thread> threadsBelow = List();

  @override
  Widget build(BuildContext context) {
    if (threadsTopFive.length == 0) fetch();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView.builder(
        itemBuilder: (context, i) {
          switch (i) {
            case 0:
              return ThreadsTopFiveWidget(threads: threadsTopFive);
          }
        },
        itemCount: 1,
      ),
      drawer: Drawer(
        child: NavigationWidget(path: 'navigation?parent=0'),
      ),
    );
  }

  void fetch() async {
    if (isFetching) return;
    setState(() => isFetching = true);

    List<Thread> newThreads = List();

    final api = ApiInheritedWidget.of(context).api;
    final json = await api.getJson('lists/1/threads');
    final jsonMap = json as Map<String, dynamic>;
    if (jsonMap.containsKey('threads')) {
      final jsonThreads = json['threads'] as List<dynamic>;
      jsonThreads
          .forEach((jsonThread) => newThreads.add(Thread.fromJson(jsonThread)));
    }

    setState(() {
      isFetching = false;

      if (newThreads.length == 0) {
        threadsTopFive.addAll(newThreads.getRange(0, 5));
        threadsBelow.addAll(newThreads.getRange(5, newThreads.length));
      } else {
        threadsBelow.addAll(newThreads);
      }
    });
  }
}

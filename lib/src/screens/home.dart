import 'package:flutter/material.dart';

import 'package:tinhte_demo/api/model/feature_page.dart';
import 'package:tinhte_demo/api/model/thread.dart';
import '../widgets/api.dart';
import '../widgets/home/feature_pages.dart';
import '../widgets/home/header.dart';
import '../widgets/home/threads_top_five.dart';
import '../widgets/navigation.dart';
import '../widgets/thread_image.dart';
import 'thread_view.dart';

const threadWidgetStartingIndex = 2;

class HomeScreen extends StatefulWidget {
  final String title;

  HomeScreen({Key key, this.title}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isFetching = false;
  final List<FeaturePage> featurePages = List();
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
            case 1:
              return FeaturePagesWidget(pages: featurePages);
            default:
              final j = i - threadWidgetStartingIndex;
              Widget widget = _buildThreadWidget(threadsBelow[j]);
              if (j == 0) {
                widget = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    HeaderWidget('Có gì mới'),
                    widget,
                  ],
                );
              }
              return widget;
          }
        },
        itemCount: threadWidgetStartingIndex + threadsBelow.length,
      ),
      drawer: Drawer(
        child: NavigationWidget(path: 'navigation?parent=0'),
      ),
    );
  }

  void fetch() async {
    if (isFetching) return;
    setState(() => isFetching = true);

    final api = ApiInheritedWidget.of(context).api;
    final ott = api.buildOneTimeToken();
    final b = api.newBatch(path: "batch?oauth_token=$ott");

    api.getJson('lists/1/threads').then((json) {
      final List<Thread> newThreads = List();

      final jsonMap = json as Map<String, dynamic>;
      if (jsonMap.containsKey('threads')) {
        final jsonThreads = json['threads'] as List<dynamic>;
        jsonThreads.forEach((j) => newThreads.add(Thread.fromJson(j)));
      }

      setState(() {
        if (threadsTopFive.length == 0) {
          threadsTopFive.addAll(newThreads.getRange(0, 5));
          threadsBelow.addAll(newThreads.getRange(5, newThreads.length));
        } else {
          threadsBelow.addAll(newThreads);
        }
      });
    });

    api.getJson('feature-pages?order=7_days_thread_count_desc').then((json) {
      final List<FeaturePage> newPages = List();

      final jsonMap = json as Map<String, dynamic>;
      if (jsonMap.containsKey('pages')) {
        final jsonPages = json['pages'] as List<dynamic>;
        jsonPages.forEach((j) {
          final fp = FeaturePage.fromJson(j);
          if (fp?.links?.image?.isNotEmpty != true) {
            return;
          }

          newPages.add(fp);
        });
      }

      setState(() => featurePages.addAll(newPages));
    });

    await b.fetch();
    setState(() => isFetching = false);
  }

  Widget _buildThreadWidget(Thread thread) => GestureDetector(
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .4,
                    child: ThreadImageWidget(image: thread?.threadImage),
                  ),
                  Expanded(
                    child: Column(
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
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        onTap: () => pushThreadViewScreen(context, thread),
      );
}

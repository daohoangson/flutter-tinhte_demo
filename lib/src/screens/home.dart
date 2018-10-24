import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:tinhte_api/feature_page.dart';
import 'package:tinhte_api/thread.dart';

import '../api.dart';
import '../widgets/home/drawer.dart';
import '../widgets/home/feature_pages.dart';
import '../widgets/home/header.dart';
import '../widgets/home/threads_top_five.dart';
import '../widgets/navigation.dart';
import '../widgets/threads.dart';

const threadWidgetStartingIndex = 2;

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<FeaturePage> featurePages = List();
  final List<Thread> threadsTopFive = List();
  final List<Thread> threadsBelow = List();

  String _title = '';

  @override
  void initState() {
    super.initState();
    fetch();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(_title),
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
                Widget widget = buildThreadRow(context, threadsBelow[j]);
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
          child: NavigationWidget(
            footer: HomeDrawerFooter(),
            header: HomeDrawerHeader(),
            path: 'navigation?parent=0',
          ),
        ),
      );

  void fetch() {
    PackageInfo.fromPlatform().then(
        (info) => setState(() => _title = "${info.appName} ${info.version}"));

    apiGet(
      this,
      'lists/1/threads',
      onSuccess: (jsonMap) {
        final List<Thread> newThreads = List();
        if (jsonMap.containsKey('threads')) {
          final jsonThreads = jsonMap['threads'] as List;
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
      },
    );

    apiGet(
      this,
      'feature-pages?order=7_days_thread_count_desc',
      onSuccess: (jsonMap) {
        final List<FeaturePage> newPages = List();

        if (jsonMap.containsKey('pages')) {
          final jsonPages = jsonMap['pages'] as List;
          jsonPages.forEach((j) {
            final fp = FeaturePage.fromJson(j);
            if (fp?.links?.image?.isNotEmpty != true) {
              return;
            }

            newPages.add(fp);
          });
        }

        setState(() => featurePages.addAll(newPages));
      },
    );
  }
}

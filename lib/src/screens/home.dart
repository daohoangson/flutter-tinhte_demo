import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:tinhte_api/feature_page.dart';
import 'package:tinhte_api/links.dart';
import 'package:tinhte_api/thread.dart';

import '../api.dart';
import '../widgets/app_bar.dart';
import '../widgets/home/feature_pages.dart';
import '../widgets/home/thread.dart';
import '../widgets/navigation.dart';

const kThreadsPath = 'lists/1/threads';

const _kFeaturePagesIndex = 5;
const _kItemCountForFeaturePages = 1;
const _kItemCountForNext = 1;

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<FeaturePage> featurePages = List();
  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey = GlobalKey();
  final List<Thread> threads = List();

  bool _isFetchingThreads = false;
  String _next;
  String _title = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => refreshIndicatorKey.currentState.show());
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(_title),
          actions: <Widget>[
            AppBarNotificationButton(),
          ],
        ),
        body: RefreshIndicator(
          key: refreshIndicatorKey,
          onRefresh: fetch,
          child: ListView.builder(
            itemBuilder: (context, i) {
              if (i < _kFeaturePagesIndex) {
                return HomeThreadWidget(i < threads.length ? threads[i] : null);
              }

              if (i == _kFeaturePagesIndex) {
                return FeaturePagesWidget(featurePages);
              }

              i--;
              if (i < threads.length) {
                return HomeThreadWidget(threads[i]);
              }

              return _next != null
                  ? RaisedButton(
                      child: Text('Next'),
                      onPressed: () => fetchNext(),
                    )
                  : _isFetchingThreads
                      ? const Center(child: CircularProgressIndicator())
                      : Container(height: 0.0, width: 0.0);
            },
            itemCount: threads.length +
                _kItemCountForFeaturePages +
                _kItemCountForNext,
          ),
        ),
      );

  Future fetch() {
    setState(() {
      featurePages.clear();
      threads.clear();
      _next = null;
    });

    return Future.wait([
      _detectTitle(),
      _fetchThreads(kThreadsPath),
    ]);
  }

  void fetchNext() {
    final next = _next;
    setState(() => _next = null);
    if (next?.isNotEmpty != true) return;

    _fetchThreads(next);
  }

  Future _detectTitle() => PackageInfo.fromPlatform().then(
      (info) => setState(() => _title = "${info.appName} ${info.version}"));

  Future _fetchThreads(String path) {
    setState(() => _isFetchingThreads = true);
    return apiGet(
      this,
      path,
      onSuccess: (jsonMap) {
        final List<Thread> nextThreads = List();
        String nextNext;

        if (jsonMap.containsKey('threads')) {
          final jsonThreads = jsonMap['threads'] as List;
          jsonThreads.forEach((j) => nextThreads.add(Thread.fromJson(j)));
        }

        if (jsonMap.containsKey('links')) {
          final links = Links.fromJson(jsonMap['links']);
          nextNext = links.next;
        }

        setState(() {
          threads.addAll(nextThreads);
          _next = nextNext;
        });
      },
      onComplete: () => setState(() => _isFetchingThreads = false),
    );
  }
}

class HomeScreenRoute extends MaterialPageRoute {
  HomeScreenRoute() : super(builder: (_) => HomeScreen());
}

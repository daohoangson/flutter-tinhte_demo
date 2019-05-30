import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:tinhte_api/content_list.dart';
import 'package:tinhte_api/feature_page.dart';

import '../widgets/app_bar.dart';
import '../widgets/home/channels.dart';
import '../widgets/home/feature_pages.dart';
import '../widgets/home/thread.dart';
import '../widgets/home/top_5.dart';
import '../widgets/super_list.dart';
import 'search/thread.dart';
import 'content_list_view.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _featurePages = <FeaturePage>[];

  var _fabIsVisible = true;
  String _title = '';

  @override
  void initState() {
    super.initState();
    _detectTitle();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(_title),
          automaticallyImplyLeading: false,
          leading: AppBarMenuIconButton(),
          actions: <Widget>[
            AppBarNotificationButton(visibleOnZero: true),
          ],
        ),
        body: NotificationListener<ScrollNotification>(
          child: SuperListView<_HomeListItem>(
            fetchPathInitial: 'lists/1/threads?limit=20'
                '&_bdImageApiThreadThumbnailWidth=${(kContentListViewThumbnailWidth * 3).toInt()}'
                '&_bdImageApiThreadThumbnailHeight=sh',
            fetchOnSuccess: _fetchOnSuccess,
            itemBuilder: (context, state, item) {
              if (item.widget != null) return item.widget;

              if (item.top5?.length == 5) {
                return HomeTop5Widget(item.top5);
              }

              if (item.thread != null)
                return HomeThreadWidget(
                  item.thread,
                  imageWidth: kContentListViewThumbnailWidth,
                );

              return null;
            },
          ),
          onNotification: (scrollInfo) {
            if (scrollInfo is ScrollUpdateNotification) {
              setState(() => _fabIsVisible = scrollInfo.scrollDelta < 0.0);
            }
          },
        ),
        floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
        floatingActionButton: _fabIsVisible
            ? FloatingActionButton(
                child: Icon(Icons.search),
                onPressed: () => showSearch(
                      context: context,
                      delegate: ThreadSearchDelegate(),
                    ),
              )
            : null,
      );

  void _detectTitle() => PackageInfo.fromPlatform().then(
      (info) => setState(() => _title = "${info.version}+${info.buildNumber}"));

  void _fetchOnSuccess(Map json, FetchContext<_HomeListItem> fc) {
    if (!json.containsKey('threads')) return;

    List<ThreadListItem> top5;
    if (fc.id == FetchContextId.FetchInitial) {
      top5 = [];
      fc.addItem(_HomeListItem(top5: top5));
      fc.addItem(_HomeListItem(widget: ChannelsWidget()));
      fc.addItem(_HomeListItem(
        widget: SuperListItemFullWidth(
          child: FeaturePagesWidget(_featurePages),
        ),
      ));
    }

    final threadsJson = json['threads'] as List;
    for (final threadJson in threadsJson) {
      final tli = ThreadListItem.fromJson(threadJson);

      if (top5 != null && top5.length < 5) {
        top5.add(tli);
      } else {
        fc.addItem(_HomeListItem(thread: tli));
      }
    }
  }
}

class HomeScreenRoute extends MaterialPageRoute {
  HomeScreenRoute() : super(builder: (_) => HomeScreen());
}

class _HomeListItem {
  final ThreadListItem thread;
  final List<ThreadListItem> top5;
  final Widget widget;

  _HomeListItem({
    this.thread,
    this.top5,
    this.widget,
  });
}

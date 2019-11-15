import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:tinhte_api/content_list.dart';
import 'package:tinhte_api/feature_page.dart';

import '../widgets/app_bar.dart';
import '../widgets/home/bottom_bar.dart';
import '../widgets/home/channels.dart';
import '../widgets/home/feature_pages.dart';
import '../widgets/home/thread.dart';
import '../widgets/home/top_5.dart';
import '../widgets/home/top_threads.dart';
import '../widgets/home/trending_tags.dart';
import '../widgets/super_list.dart';
import 'content_list_view.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _featurePages = <FeaturePage>[];

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
          actions: <Widget>[
            AppBarNotificationButton(visibleOnZero: true),
          ],
        ),
        body: SuperListView<_HomeListItem>(
          complexItems: [
            TopThreadsWidget.registerSuperListComplexItem,
            TrendingTagsWidget.registerSuperListComplexItem,
          ],
          fetchPathInitial: 'lists/1/threads?limit=20'
              '&_bdImageApiThreadThumbnailWidth=${(kContentListViewThumbnailWidth * 3).toInt()}'
              '&_bdImageApiThreadThumbnailHeight=sh',
          fetchOnSuccess: _fetchOnSuccess,
          itemBuilder: (context, state, item) {
            if (item.widget != null) return item.widget;

            if (item.top5?.length == 5) {
              return SuperListItemFullWidth(
                child: HomeTop5Widget(item.top5),
              );
            }

            if (item.thread != null)
              return HomeThreadWidget(
                item.thread,
                imageWidth: kContentListViewThumbnailWidth,
              );

            return null;
          },
          itemMaxWidth: 800,
        ),
        bottomNavigationBar: HomeBottomBar(),
      );

  void _detectTitle() => PackageInfo.fromPlatform().then(
      (info) => setState(() => _title = "${info.version}+${info.buildNumber}"));

  void _fetchOnSuccess(Map json, FetchContext<_HomeListItem> fc) {
    if (!json.containsKey('threads')) return;

    List<ThreadListItem> top5;
    if (fc.id == FetchContextId.FetchInitial) {
      top5 = [];
      fc.addItem(_HomeListItem(top5: top5));
      fc.addItem(_HomeListItem(
        widget: SuperListItemFullWidth(
          child: ChannelsWidget(),
        ),
      ));
      fc.addItem(_HomeListItem(
        widget: SuperListItemFullWidth(
          child: FeaturePagesWidget(_featurePages),
        ),
      ));
    }

    final threadsJson = json['threads'] as List;
    final l = threadsJson.length;
    for (int i = 0; i < l; i++) {
      final Map threadJson = threadsJson[i];
      final tli = ThreadListItem.fromJson(threadJson);

      if (tli?.thread?.threadImage != null) {
        // force display mode for edge case: when thread has custom home image
        // thread view will have an annoying jump effect (no cover -> has cover)
        // we know home thread always has cover image so it's safe to do this
        tli.thread.threadImage.displayMode = 'cover';
      }

      if (top5 != null && top5.length < 5) {
        top5.add(tli);
      } else {
        fc.addItem(_HomeListItem(thread: tli));
      }

      if (fc.id == FetchContextId.FetchInitial && i == l - 4) {
        fc.addItem(_HomeListItem(
          widget: SuperListItemFullWidth(
            child: TrendingTagsWidget(),
          ),
        ));
      }
    }

    if (fc.id == FetchContextId.FetchInitial) {
      fc.addItem(_HomeListItem(
        widget: SuperListItemFullWidth(
          child: TopThreadsWidget(),
        ),
      ));
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

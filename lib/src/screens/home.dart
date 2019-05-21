import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:tinhte_api/content_list.dart';
import 'package:tinhte_api/feature_page.dart';

import '../widgets/app_bar.dart';
import '../widgets/home/feature_pages.dart';
import '../widgets/home/thread.dart';
import '../widgets/super_list.dart';
import '../push_notification.dart';

const _kFeaturePagesIndex = 5;

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey = GlobalKey();

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
          automaticallyImplyLeading: false,
          leading: AppBarMenuIconButton(),
          actions: <Widget>[
            AppBarNotificationButton(),
          ],
        ),
        body: SuperListView<_HomeListItem>(
          fetchPathInitial: 'lists/1/threads',
          fetchOnSuccess: _fetchOnSuccess,
          itemBuilder: (context, state, item) {
            if (item.featurePages == true)
              return SuperListItemFullWidth(
                child: FeaturePagesWidget(_featurePages),
              );

            if (item.thread != null) return HomeThreadWidget(item.thread);

            return null;
          },
        ),
      );

  void _detectTitle() => PackageInfo.fromPlatform().then(
      (info) => setState(() => _title = "${info.version}+${info.buildNumber}"));

  void _fetchOnSuccess(Map json, FetchContext<_HomeListItem> fc) {
    if (!json.containsKey('threads')) return;

    final threadsJson = json['threads'] as List;
    for (final threadJson in threadsJson) {
      final tli = ThreadListItem.fromJson(threadJson);
      fc.addItem(_HomeListItem(thread: tli));

      if (fc.id == FetchContextId.FetchInitial &&
          fc.items?.length == _kFeaturePagesIndex) {
        fc.addItem(_HomeListItem(featurePages: true));
      }
    }
  }
}

class HomeScreenRoute extends MaterialPageRoute {
  HomeScreenRoute()
      : super(
          builder: (_) => PushNotificationApp(HomeScreen()),
        );
}

class _HomeListItem {
  final bool featurePages;
  final ThreadListItem thread;

  _HomeListItem({
    this.featurePages,
    this.thread,
  });
}

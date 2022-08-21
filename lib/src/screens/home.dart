import 'package:flutter/material.dart';
import 'package:the_api/search.dart';
import 'package:the_api/thread.dart';
import 'package:the_app/src/screens/thread_create.dart';
import 'package:the_app/src/widgets/home/bottom_bar.dart';
import 'package:the_app/src/widgets/home/thread.dart';
import 'package:the_app/src/widgets/home/top_5.dart';
import 'package:the_app/src/widgets/super_list.dart';
import 'package:the_app/src/config.dart';
import 'package:the_app/src/intl.dart';

class HomeScreen extends StatelessWidget {
  final superList = GlobalKey<SuperListState>();

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: SuperListView<_HomeListItem>(
            complexItems: config.homeComplexItems,
            fetchPathInitial: config.homePath,
            fetchOnSuccess: _fetchOnSuccess,
            itemBuilder: (context, state, item) {
              if (item.widget != null) return item.widget;

              if (item.top5?.length == 5) {
                return SuperListItemFullWidth(
                  child: HomeTop5Widget(item.top5),
                );
              }

              final itemThread = item.thread;
              if (itemThread != null) return HomeThreadWidget(itemThread);

              return null;
            },
            itemMaxWidth: 800,
            key: superList,
          ),
          top: false,
          bottom: false,
        ),
        bottomNavigationBar: HomeBottomBar(
          onHomeTap: () => superList.currentState?.scrollTo(0),
        ),
        extendBody: true,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => ThreadCreateScreen())),
          tooltip: l(context).threadCreateNew,
          child: Icon(Icons.add),
          elevation: 2.0,
        ),
      );

  void _fetchOnSuccess(Map json, FetchContext<_HomeListItem> fc) {
    if (!json.containsKey(config.homeThreadsKey)) return;
    final threadsJson = json[config.homeThreadsKey] as List;
    final l = threadsJson.length;

    final items = fc.items;
    List<SearchResult<Thread>> top5;
    if (fc.id == FetchContextId.FetchInitial && l >= 5) {
      top5 = [];
      items.add(_HomeListItem(top5: top5));

      final slot1 = config.homeSlot1BelowTop5;
      if (slot1 != null) items.add(_HomeListItem(widget: slot1));

      final slot2 = config.homeSlot2BelowSlot1;
      if (slot2 != null) items.add(_HomeListItem(widget: slot2));
    }

    for (int i = 0; i < l; i++) {
      var srt = config.homeParser(threadsJson[i]);
      if (srt == null || srt.content == null) continue;

      if (top5 != null && top5.length < 5) {
        top5.add(srt);
      } else {
        items.add(_HomeListItem(thread: srt));
      }

      if (fc.id == FetchContextId.FetchInitial && i == l - 4) {
        final slot3 = config.homeSlot3NearEndOfPage1;
        if (slot3 != null) items.add(_HomeListItem(widget: slot3));
      }
    }

    if (fc.id == FetchContextId.FetchInitial) {
      final slot4 = config.homeSlot4EndOfPage1;
      if (slot4 != null) items.add(_HomeListItem(widget: slot4));
    }
  }
}

class HomeScreenRoute extends MaterialPageRoute {
  HomeScreenRoute() : super(builder: (_) => HomeScreen());
}

class _HomeListItem {
  final SearchResult<Thread> thread;
  final List<SearchResult<Thread>> top5;
  final Widget widget;

  _HomeListItem({
    this.thread,
    this.top5,
    this.widget,
  });
}

import 'package:flutter/material.dart';
import 'package:tinhte_api/search.dart';
import 'package:tinhte_api/thread.dart';
import 'package:tinhte_demo/src/constants.dart';
import 'package:tinhte_demo/src/screens/thread_create.dart';
import 'package:tinhte_demo/src/widgets/home/bottom_bar.dart';
import 'package:tinhte_demo/src/widgets/home/thread.dart';
import 'package:tinhte_demo/src/widgets/home/top_5.dart';
import 'package:tinhte_demo/src/widgets/super_list.dart';
import 'package:tinhte_demo/src/config.dart';
import 'package:tinhte_demo/src/intl.dart';

class HomeScreen extends StatelessWidget {
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

              if (item.thread != null) return HomeThreadWidget(item.thread);

              return null;
            },
            itemMaxWidth: 800,
          ),
        ),
        bottomNavigationBar: HomeBottomBar(),
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
    if (!json.containsKey('threads')) return;

    final items = fc.items;
    List<SearchResult<Thread>> top5;
    if (fc.id == FetchContextId.FetchInitial) {
      top5 = [];
      items.add(_HomeListItem(top5: top5));

      final slot1 = config.homeSlot1BelowTop5;
      if (slot1 != null) items.add(_HomeListItem(widget: slot1));

      final slot2 = config.homeSlot2BelowSlot1;
      if (slot2 != null) items.add(_HomeListItem(widget: slot2));
    }

    final threadsJson = json[config.homeThreadsKey] as List;
    final l = threadsJson.length;
    for (int i = 0; i < l; i++) {
      var srt = config.homeParser(threadsJson[i]);
      if (srt == null || srt.content == null) continue;

      if (srt.content?.threadImage != null) {
        // force display mode for edge case: when thread has custom home image
        // thread view will have an annoying jump effect (no cover -> has cover)
        // we know home thread always has cover image so it's safe to do this
        srt.content.threadImage.displayMode = 'cover';
      }

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

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:tinhte_api/navigation.dart' as navigation;
import 'package:tinhte_api/node.dart';
import 'package:tinhte_api/post.dart';
import 'package:tinhte_api/thread.dart';
import 'package:tinhte_api/x_user_feed.dart';
import 'package:tinhte_demo/src/screens/forum_view.dart';
import 'package:tinhte_demo/src/screens/node_view.dart';
import 'package:tinhte_demo/src/screens/thread_view.dart';
import 'package:tinhte_demo/src/widgets/tinhte/background_post.dart';
import 'package:tinhte_demo/src/widgets/tinhte/tinhte_fact.dart';
import 'package:tinhte_demo/src/widgets/super_list.dart';
import 'package:tinhte_demo/src/widgets/image.dart';
import 'package:tinhte_demo/src/api.dart';
import 'package:tinhte_demo/src/config.dart';
import 'package:tinhte_demo/src/intl.dart';
import 'package:tinhte_demo/src/link.dart';
import 'package:tinhte_demo/src/widgets/x_user_feed/thread.dart';

part 'thread/navigation.dart';
part 'thread/widget.dart';

class ThreadsWidget extends StatelessWidget {
  final ApiMethod apiMethod;
  final Forum forum;
  final Widget header;
  final Map initialJson;
  final String path;
  final String threadsKey;

  ThreadsWidget({
    this.apiMethod,
    this.forum,
    this.header,
    this.initialJson,
    Key key,
    this.path,
    this.threadsKey = 'threads',
  }) : super(key: key);

  @override
  Widget build(BuildContext _) => SuperListView<Thread>(
        apiMethodInitial: apiMethod,
        fetchOnSuccess: _fetchOnSuccess,
        fetchPathInitial: path,
        initialJson: initialJson,
        header: header,
        itemBuilder: (_, __, thread) => ThreadWidget(thread),
      );

  void _fetchOnSuccess(Map json, FetchContext<Thread> fc) {
    if (!json.containsKey(threadsKey)) return;

    final list = json[threadsKey] as List;
    for (final j in list) {
      final thread = Thread.fromJson(j);
      if (thread.threadId == null || thread.firstPost == null) continue;

      if (thread.forum == null && thread.forumId == forum?.forumId)
        thread.forum = forum;

      fc.items.add(thread);
    }
  }
}

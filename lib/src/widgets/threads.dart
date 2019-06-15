import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share/share.dart';
import 'package:tinhte_api/navigation.dart' as navigation;
import 'package:tinhte_api/node.dart';
import 'package:tinhte_api/post.dart';
import 'package:tinhte_api/thread.dart';
import 'package:tinhte_demo/src/link.dart';

import '../screens/forum_view.dart';
import '../screens/node_view.dart';
import '../screens/thread_view.dart';
import '../api.dart';
import '../intl.dart';
import 'super_list.dart';
import 'image.dart';

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

    final jsonThreads = json[threadsKey] as List;
    jsonThreads.forEach((j) {
      final thread = Thread.fromJson(j);
      if (thread.threadId == null || thread.firstPost == null) return;

      if (thread.forum == null && thread.forumId == forum?.forumId) {
        thread.forum = forum;
      }

      fc.addItem(thread);
    });
  }
}

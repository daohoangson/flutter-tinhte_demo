import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:the_api/node.dart';
import 'package:the_api/post.dart';
import 'package:the_api/thread.dart';
import 'package:the_api/x_user_feed.dart';
import 'package:the_app/src/screens/forum_view.dart';
import 'package:the_app/src/screens/node_view.dart';
import 'package:the_app/src/screens/thread_view.dart';
import 'package:the_app/src/widgets/tinhte/background_post.dart';
import 'package:the_app/src/widgets/tinhte/tinhte_fact.dart';
import 'package:the_app/src/widgets/super_list.dart';
import 'package:the_app/src/widgets/image.dart';
import 'package:the_app/src/api.dart';
import 'package:the_app/src/config.dart';
import 'package:the_app/src/intl.dart';
import 'package:the_app/src/link.dart';
import 'package:the_app/src/widgets/x_user_feed/thread.dart';

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

      final threadWithForum =
          (thread.forum == null && thread.forumId == forum?.forumId)
              ? thread.copyWith(forum: forum)
              : thread;

      fc.items.add(threadWithForum);
    }
  }
}

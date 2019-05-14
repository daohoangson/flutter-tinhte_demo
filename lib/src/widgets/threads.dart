import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tinhte_api/thread.dart';

import '../screens/thread_view.dart';
import '../constants.dart';
import '../intl.dart';
import 'super_list.dart';
import 'image.dart';

part 'thread/builders.dart';

class ThreadsWidget extends StatelessWidget {
  final Widget header;
  final Map initialJson;
  final String path;
  final String threadsKey;

  ThreadsWidget({
    this.header,
    this.initialJson,
    Key key,
    this.path,
    this.threadsKey = 'threads',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => SuperListView<Thread>(
        fetchOnSuccess: _fetchOnSuccess,
        fetchPathInitial: path,
        initialJson: initialJson,
        header: header,
        itemBuilder: (context, _, thread) => buildThreadRow(context, thread),
      );

  void _fetchOnSuccess(Map json, FetchContext<Thread> fc) {
    if (!json.containsKey(threadsKey)) return;

    final jsonThreads = json[threadsKey] as List;
    jsonThreads.forEach((j) {
      final thread = Thread.fromJson(j);
      if (thread.threadId == null || thread.firstPost == null) return;

      fc.addItem(thread);
    });
  }
}

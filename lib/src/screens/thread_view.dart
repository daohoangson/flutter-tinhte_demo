import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tinhte_api/thread.dart';

import '../widgets/app_bar.dart';
import '../widgets/posts.dart';
import '../intl.dart';
import '../link.dart';

class ThreadViewScreen extends StatefulWidget {
  final Thread thread;
  final Map initialJson;

  ThreadViewScreen(
    this.thread, {
    this.initialJson,
    Key key,
  })  : assert(thread != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() => _ThreadViewState();
}

class _ThreadViewState extends State<ThreadViewScreen> {
  Map get initialJson => widget.initialJson;
  Thread get thread => widget.thread;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: buildAppBar(
          title: _buildAppBarTitle(),
        ),
        body: _buildBody(),
      );

  Widget _buildAppBarTitle() => GestureDetector(
        child: Row(
          children: <Widget>[
            CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(
                thread.links?.firstPosterAvatar,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 7.5,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Text(
                      thread.creatorUsername,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: (kToolbarHeight - 10) / 2),
                    ),
                    Text(
                      formatTimestamp(thread.threadCreateDate),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: (kToolbarHeight - 10) / 4),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        onTap: () => launchMemberView(this, thread.creatorUserId),
      );

  Widget _buildBody() => PostsWidget(
        path: thread.links?.posts,
        initialJson: initialJson,
        thread: thread,
      );
}

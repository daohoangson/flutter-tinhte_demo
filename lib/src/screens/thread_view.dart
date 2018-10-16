import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tinhte_api/thread.dart';

import '../intl.dart';
import '../widgets/posts.dart';
import '../widgets/image.dart';

void pushThreadViewScreen(BuildContext context, Thread thread) {
  if (thread == null) return;

  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => ThreadViewScreen(thread: thread)),
  );
}

class ThreadViewScreen extends StatelessWidget {
  final Thread thread;

  ThreadViewScreen({Key key, this.thread}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final body = PostsWidget(
      infinityScrolling: false,
      path: thread.links.posts + '&limit=100',
      thread: thread,
    );

    final title = Row(
      children: <Widget>[
        CircleAvatar(
          backgroundImage:
              CachedNetworkImageProvider(thread.links.firstPosterAvatar),
        ),
        Expanded(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  thread.firstPost.posterUsername,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  formatTimestamp(thread.firstPost.postCreateDate),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12.0),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    if (thread?.threadImage == null) {
      return Scaffold(
        appBar: AppBar(
          title: title,
        ),
        body: body,
      );
    }

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight:
                  MediaQuery.of(context).size.width / kThreadImageAspectRatio -
                      kToolbarHeight,
              flexibleSpace: FlexibleSpaceBar(
                background: ThreadImageWidget(
                  image: thread.threadImage,
                  threadId: thread.threadId,
                ),
              ),
              pinned: true,
              title: title,
            ),
          ];
        },
        body: body,
      ),
    );
  }
}

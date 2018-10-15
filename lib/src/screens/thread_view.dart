import 'package:flutter/material.dart';
import 'package:tinhte_api/thread.dart';

import '../widgets/posts.dart';
import '../widgets/thread_image.dart';

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
      path: thread.links.posts,
      thread: thread,
    );

    if (thread?.threadImage == null) {
      return Scaffold(
        appBar: AppBar(),
        body: body,
      );
    }

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight:
                  MediaQuery.of(context).size.width / ThreadImageAspectRatio -
                      kToolbarHeight,
              flexibleSpace: FlexibleSpaceBar(
                background: ThreadImageWidget(image: thread.threadImage),
              ),
              pinned: true,
            ),
          ];
        },
        body: body,
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:tinhte_demo/api/model/thread.dart';
import '../widgets/posts.dart';
import '../widgets/thread_image.dart';

class ThreadViewScreen extends StatelessWidget {
  final Thread thread;

  ThreadViewScreen({Key key, this.thread}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final title = Text(
      thread.threadTitle,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.start,
    );
    final body = PostsWidget(
      path: "posts?thread_id=${thread.threadId}",
      thread: thread,
    );

    if (thread?.threadImage == null) {
      return Scaffold(
        appBar: AppBar(title: title),
        body: body,
      );
    }

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: MediaQuery.of(context).size.width / ThreadImageAspectRatio,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: false,
                title: title,
                background: ThreadImageWidget(image: thread.threadImage),
              ),
            ),
          ];
        },
        body: body,
      ),
    );
  }
}

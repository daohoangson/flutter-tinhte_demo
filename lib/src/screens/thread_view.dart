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
    MaterialPageRoute(builder: (context) => ThreadViewScreen(thread)),
  );
}

class ThreadViewScreen extends StatelessWidget {
  final Thread thread;

  ThreadViewScreen(this.thread, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      thread?.threadImage?.displayMode == 'cover'
          ? buildThreadWithCoverImage()
          : buildThreadNoImage();

  Widget buildThreadNoImage() => Scaffold(
        appBar: AppBar(
          title: _buildAppBarTitle(),
        ),
        body: _buildBody(),
      );

  Widget buildThreadWithCoverImage() => Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => <Widget>[
                SliverAppBar(
                  expandedHeight: MediaQuery.of(context).size.width /
                          kThreadImageAspectRatio -
                      kToolbarHeight,
                  flexibleSpace: FlexibleSpaceBar(
                    background: ThreadImageWidget(
                      image: thread.threadImage,
                      threadId: thread.threadId,
                    ),
                  ),
                  pinned: true,
                  title: _buildAppBarTitle(),
                ),
              ],
          body: _buildBody(),
        ),
      );

  Widget _buildAppBarTitle() => Row(
        children: <Widget>[
          CircleAvatar(
            backgroundImage:
                CachedNetworkImageProvider(thread.links.firstPosterAvatar),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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

  Widget _buildBody() => PostsWidget(
        path: thread.links.posts,
        thread: thread,
      );
}

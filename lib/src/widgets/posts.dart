import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tinhte_api/links.dart';
import 'package:tinhte_api/post.dart';
import 'package:tinhte_api/thread.dart';

import '../intl.dart';
import '_list_view.dart';
import '_api.dart';
import 'html.dart';

const kPaddingHorizontal = 10.0;

Widget _buildDecoratedBox(BuildContext context, Widget child) => DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2.0),
        color: Theme.of(context).highlightColor,
      ),
      child: Padding(padding: const EdgeInsets.only(top: 10.0), child: child),
    );

Widget _buildPostReply(BuildContext context, Post post) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: kPaddingHorizontal),
          child: _buildPosterCircleAvatar(post, 15.0),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: kPaddingHorizontal),
                child: _buildDecoratedBox(
                  context,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: kPaddingHorizontal),
                        child: RichText(
                          text: _buildPostTextSpan(context, post),
                        ),
                      ),
                      TinhteHtmlWidget(post.postBodyHtml),
                    ],
                  ),
                ),
              ),
              _PostActionsWidget(post),
            ],
          ),
        ),
      ],
    );

TextSpan _buildPostTextSpan(BuildContext context, Post post) => TextSpan(
      children: <TextSpan>[
        TextSpan(
          style: TextStyle(
            color: Theme.of(context).accentColor,
            fontWeight: FontWeight.bold,
          ),
          text: post.posterUsername,
        ),
        TextSpan(
          style: TextStyle(
            color: Theme.of(context).disabledColor,
          ),
          text: "  ${formatTimestamp(post.postCreateDate)}",
        ),
      ],
      style: DefaultTextStyle.of(context).style.copyWith(
            fontSize: 12.0,
          ),
    );

Widget _buildPosterCircleAvatar(Post post, double radius) => CircleAvatar(
      backgroundImage: CachedNetworkImageProvider(post.links.posterAvatar),
      radius: radius,
    );

class PostsWidget extends StatefulWidget {
  final bool infinityScrolling;
  final String path;
  final Thread thread;

  PostsWidget({
    Key key,
    @required this.path,
    this.thread,
    bool infinityScrolling = true,
  })  : this.infinityScrolling = infinityScrolling == true,
        super(key: key);

  @override
  _PostsWidgetState createState() => _PostsWidgetState(this.path);
}

class _PostsWidgetState extends State<PostsWidget> {
  bool isFetching = false;
  final List<Post> posts = List();
  String url;

  _PostsWidgetState(this.url);

  @override
  Widget build(BuildContext context) {
    if (posts.length == 0) {
      fetch();
    }

    final listView = ListView.builder(
      controller: PrimaryScrollController.of(context),
      itemBuilder: (context, i) {
        if (i == posts.length) {
          return buildProgressIndicator(isFetching);
        }
        return _buildRow(posts[i]);
      },
      itemCount: posts.length + 1,
      padding: const EdgeInsets.all(0.0),
    );

    if (!widget.infinityScrolling) return listView;

    return NotificationListener<ScrollNotification>(
      child: listView,
      onNotification: (scrollInfo) {
        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          fetch();
        }
      },
    );
  }

  void fetch() async {
    if (isFetching || url == null) {
      return;
    }

    setState(() {
      isFetching = true;

      if (posts.length == 0) {
        final thread = widget.thread;
        if (thread != null) {
          final firstPost = thread.firstPost;
          if (firstPost != null) {
            posts.add(firstPost);
          }
        }
      }
    });

    List<Post> newPosts = List();
    String newUrl;

    final api = ApiInheritedWidget.of(context).api;
    final json = await api.getJson(url);
    final jsonMap = json as Map<String, dynamic>;
    if (jsonMap.containsKey('posts')) {
      final decodedPosts = decodePostsAndTheirReplies(json['posts']);
      decodedPosts.forEach((post) {
        if (post.postIsFirstPost &&
            post.postId == widget.thread?.firstPost?.postId) {
          return;
        }

        newPosts.add(post);
      });
    }

    if (jsonMap.containsKey('links')) {
      final links = Links.fromJson(json['links']);
      newUrl = links.next;
    }

    setState(() {
      isFetching = false;
      posts.addAll(newPosts);
      url = newUrl;
    });
  }

  Widget _buildRow(Post post) {
    Widget header;
    if (post.postIsFirstPost) {
      header = Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: kPaddingHorizontal, vertical: 10.0),
        child: Text(
          widget.thread.threadTitle,
          maxLines: null,
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else {
      header = Padding(
        padding: const EdgeInsets.symmetric(horizontal: kPaddingHorizontal),
        child: RichText(
          text: _buildPostTextSpan(context, post),
        ),
      );
    }

    final html = TinhteHtmlWidget(
      post.postBodyHtml,
      isFirstPost: post.postIsFirstPost,
    );

    Widget built;
    if (post.postIsFirstPost) {
      built = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          header,
          html,
          _PostActionsWidget(post),
        ],
      );
    } else {
      built = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: kPaddingHorizontal),
            child: _buildPosterCircleAvatar(post, 18.0),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: kPaddingHorizontal),
                  child: _buildDecoratedBox(
                    context,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        header,
                        html,
                      ],
                    ),
                  ),
                ),
                _PostActionsWidget(post),
                _PostRepliesWidget(post),
              ],
            ),
          ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: built,
    );
  }
}

class _PostActionsWidget extends StatefulWidget {
  final Post post;
  _PostActionsWidget(this.post, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PostActionsWidgetState();
}

class _PostActionsWidgetState extends State<_PostActionsWidget> {
  bool postIsLiked;
  int postLikeCount;

  @override
  void initState() {
    super.initState();

    postIsLiked = widget.post.postIsLiked == true;
    postLikeCount = widget.post.postLikeCount ?? 0;
  }

  @override
  Widget build(BuildContext context) => Row(
        children: <Widget>[
          _buildButton(
            postIsLiked ? 'Unlike' : 'Like',
            () => postIsLiked ? _unlikePost() : _likePost(),
            count: postLikeCount,
          ),
          _buildButton('Reply', () => null),
        ],
      );

  Widget _buildButton(String text, GestureTapCallback onTap, {int count = 0}) =>
      InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: kPaddingHorizontal, vertical: 5.0),
          child: Text(
            (count > 0 ? "$count " : '') + text,
            style: TextStyle(
              color: Theme.of(context).accentColor,
              fontSize: 12.0,
            ),
          ),
        ),
      );

  _likePost() => prepareForApiAction(context, (apiData) async {
        await apiData.api.postJson(widget.post.links.likes);

        setState(() {
          postIsLiked = true;
          postLikeCount++;
        });
      });

  _unlikePost() => prepareForApiAction(context, (apiData) async {
        await apiData.api.deleteJson(widget.post.links.likes);

        setState(() {
          postIsLiked = false;
          if (postLikeCount > 0) postLikeCount--;
        });
      });
}

class _PostRepliesWidget extends StatelessWidget {
  final Post parent;

  _PostRepliesWidget(this.parent, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final replies = parent?.postReplies;
    if (replies == null) return Container(height: 0.0, width: 0.0);

    final List<Widget> children = List();
    for (final reply in replies) {
      if (reply.post != null) {
        children.add(_buildPostReply(context, reply.post));
        continue;
      }

      if (reply.link?.isNotEmpty == true) {
        children.add(_PostReplyHiddenWidget(reply.link, reply.postReplyCount));
        continue;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}

class _PostReplyHiddenWidget extends StatefulWidget {
  final String link;
  final int postReplyCount;

  _PostReplyHiddenWidget(this.link, this.postReplyCount, {Key key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _PostReplyHiddenWidgetState();
}

class _PostReplyHiddenWidgetState extends State<_PostReplyHiddenWidget> {
  bool hasStartedFetching = false;
  List<Post> posts;

  @override
  Widget build(BuildContext context) {
    if (posts == null) {
      if (hasStartedFetching) {
        return Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: kPaddingHorizontal, vertical: 10.0),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      return Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: kPaddingHorizontal, vertical: 10.0),
        child: GestureDetector(
          child: Text(
            "Tap to load ${widget.postReplyCount} hidden replies...",
            style: DefaultTextStyle.of(context).style.copyWith(
                  color: Theme.of(context).primaryColorLight,
                  fontSize: 12.0,
                ),
          ),
          onTap: () => fetchHiddenReplies(),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: posts.map((p) => _buildPostReply(context, p)).toList(),
    );
  }

  void fetchHiddenReplies() async {
    if (hasStartedFetching || widget.link == null) {
      return;
    }

    setState(() => hasStartedFetching = true);

    final api = ApiInheritedWidget.of(context).api;
    final json = await api.getJson(widget.link);
    final jsonMap = json as Map<String, dynamic>;
    if (jsonMap.containsKey('replies')) {
      final decodedPosts = decodePostsAndTheirReplies(json['replies']);
      setState(() => posts = decodedPosts);
      return;
    }

    setState(() => posts = List(0));
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tinhte_api/links.dart';
import 'package:tinhte_api/post.dart';
import 'package:tinhte_api/thread.dart';

import '../intl.dart';
import '_list_view.dart';
import '_api.dart';
import 'html.dart';

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
      final jsonPosts = json['posts'] as List<dynamic>;
      jsonPosts.forEach((jsonPost) {
        final post = Post.fromJson(jsonPost);
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
        padding: const EdgeInsets.all(10.0),
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
        padding: const EdgeInsets.only(right: 10.0, left: 10.0),
        child: RichText(
          text: _buildPostTextSpan(post),
        ),
      );
    }

    final html = HtmlWidget(
      html: post.postBodyHtml,
      isFirstPost: post.postIsFirstPost,
    );

    final actions = _PostActionsWidget(post: post);

    Widget built;
    if (post.postIsFirstPost) {
      built = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          header,
          html,
          actions,
        ],
      );
    } else {
      built = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: CircleAvatar(
              backgroundImage:
                  CachedNetworkImageProvider(post.links.posterAvatar),
              radius: 18.0,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2.0),
                      color: Theme.of(context).highlightColor,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          header,
                          html,
                        ],
                      ),
                    ),
                  ),
                ),
                actions,
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

  TextSpan _buildPostTextSpan(Post post) => TextSpan(
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
}

class _PostActionsWidget extends StatefulWidget {
  final Post post;
  _PostActionsWidget({Key key, @required this.post}) : super(key: key);

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
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
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

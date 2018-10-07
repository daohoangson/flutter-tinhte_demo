import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:tinhte_demo/api/model/links.dart';
import 'package:tinhte_demo/api/model/post.dart';
import 'package:tinhte_demo/api/model/thread.dart';
import 'api.dart';
import 'html.dart';
import 'thread_image.dart';

class PostsWidget extends StatefulWidget {
  final String path;
  final Thread thread;

  PostsWidget({Key key, @required this.path, this.thread}) : super(key: key);

  @override
  _PostsWidgetState createState() => _PostsWidgetState(this.path);
}

class _PostsWidgetState extends State<PostsWidget> {
  bool isFetching = false;
  final scrollController = ScrollController();
  final List<Post> posts = List();
  String url;

  _PostsWidgetState(this.url);

  @override
  void initState() {
    super.initState();

    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        fetch();
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (posts.length == 0) {
      fetch();
    }

    return ListView.builder(
      controller: scrollController,
      itemBuilder: (context, i) {
        if (i == posts.length) {
          return _buildProgressIndicator();
        }
        return _buildRow(posts[i]);
      },
      itemCount: posts.length + 1,
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

  Widget _buildProgressIndicator() => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Opacity(
            opacity: isFetching ? 1.0 : 0.0,
            child: CircularProgressIndicator(),
          ),
        ),
      );

  Widget _buildRow(Post post) {
    final List<Widget> children = List();

    if (post.postIsFirstPost &&
        post.postId == widget.thread?.firstPost?.postId) {
      final thread = widget.thread;

      if (thread.threadImage != null) {
        children.add(ThreadImageWidget(image: thread.threadImage));
      }
    }

    children.addAll(<Widget>[
      Padding(
        padding: const EdgeInsets.all(5.0),
        child: RichText(
          text: TextSpan(
            children: <TextSpan>[
              TextSpan(
                style: TextStyle(
                  color: Theme.of(context).accentColor,
                  fontWeight: FontWeight.bold,
                ),
                text: post.posterUsername,
              ),
              TextSpan(text: ' • '),
              TextSpan(
                  style: TextStyle(
                    color: Theme.of(context).disabledColor,
                  ),
                  text: timeago.format(new DateTime.fromMillisecondsSinceEpoch(
                      post.postCreateDate * 1000))),
            ],
            style: DefaultTextStyle.of(context).style,
          ),
        ),
      ),
      HtmlWidget(html: post.postBodyHtml),
    ]);

    return Card(
      child: Column(
        children: children,
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    );
  }
}

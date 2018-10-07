import 'package:flutter/material.dart';

import 'package:tinhte_demo/api/model/post.dart';
import 'package:tinhte_demo/api/model/links.dart';
import 'api.dart';
import 'html.dart';

class PostsWidget extends StatefulWidget {
  final String path;

  PostsWidget(this.path);

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
    setState(() => isFetching = true);
    
    List<Post> newPosts = List();
    String newUrl;

    final api = ApiInheritedWidget.of(context).api;
    final json = await api.getJson(url);
    final jsonMap = json as Map<String, dynamic>;
    if (jsonMap.containsKey('posts')) {
      final jsonPosts = json['posts'] as List<dynamic>;
      jsonPosts.forEach((jsonPost) => posts.add(Post.fromJson(jsonPost)));
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

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Opacity(
          opacity: isFetching ? 1.0 : 0.0,
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildRow(Post post) {
    return Card(
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(5.0),
            child: Text(
              post.posterUsername,
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
            ),
          ),
          HtmlWidget(post.postBodyHtml),
          ButtonTheme.bar(
            child: ButtonBar(
              children: <Widget>[
                FlatButton(
                  child: const Text('LIKE'),
                  onPressed: () { /* ... */ },
                ),
                FlatButton(
                  child: const Text('COMMENT'),
                  onPressed: () { /* ... */ },
                ),
                FlatButton(
                  child: const Text('SHARE'),
                  onPressed: () { /* ... */ },
                ),
              ],
            ),
          ),
        ],
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    );
  }
}
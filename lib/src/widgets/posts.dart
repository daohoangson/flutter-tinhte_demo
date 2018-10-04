import 'package:flutter/material.dart';
import 'package:flutter_html_view/flutter_html_view.dart';

import 'package:tinhte_demo/api/model/post.dart';
import 'package:tinhte_demo/api/model/links.dart';
import 'api.dart';

class PostsWidget extends StatefulWidget {
  final String path;

  PostsWidget(this.path);

  @override
  _PostsWidgetState createState() => _PostsWidgetState(this.path);
}

class _PostsWidgetState extends State<PostsWidget> {
  bool isFetching = false;
  final scrollController = new ScrollController();
  final List<Post> posts = new List();
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

    return new ListView.builder(
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
    
    List<Post> newPosts = new List();
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
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: new Opacity(
          opacity: isFetching ? 1.0 : 0.0,
          child: new CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildRow(Post post) {
    return new Card(
      child: new Column(
        children: <Widget>[
          new Container(
            padding: const EdgeInsets.all(5.0),
            child: new Text(
              post.posterUsername,
              style: new TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
            ),
          ),
          new HtmlView(data: post.postBodyHtml),
          new ButtonTheme.bar(
            child: new ButtonBar(
              children: <Widget>[
                new FlatButton(
                  child: const Text('LIKE'),
                  onPressed: () { /* ... */ },
                ),
                new FlatButton(
                  child: const Text('COMMENT'),
                  onPressed: () { /* ... */ },
                ),
                new FlatButton(
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
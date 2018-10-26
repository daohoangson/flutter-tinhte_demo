part of '../posts.dart';

class _PostListWidget extends StatefulWidget {
  final String path;
  final Thread thread;

  _PostListWidget(
    this.thread, {
    Key key,
    this.path,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PostListWidgetState(this.path);
}

class _PostListWidgetState extends State<_PostListWidget> {
  final List<Post> posts = List();

  Widget _firstPost;
  bool _isFetching = false;
  VoidCallback _removeListener;
  String _url;

  _PostListWidgetState(this._url);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_removeListener != null) _removeListener();
    _removeListener = PostListInheritedWidget.of(context)
        .addListener((post) => setState(() => posts.insert(0, post)));

    if (posts.length == 0) fetch();
  }

  @override
  void deactivate() {
    if (_removeListener != null) {
      _removeListener();
      _removeListener = null;
    }

    super.deactivate();
  }

  @override
  Widget build(BuildContext context) => ListView.builder(
        controller: PrimaryScrollController.of(context),
        itemBuilder: (context, i) =>
            i == 0 ? _buildFirstPost() : _buildPostRoot(posts[i - 1]),
        itemCount: 1 + posts.length,
      );

  fetch() {
    if (_isFetching || _url?.isNotEmpty != true) return;
    setState(() => _isFetching = true);

    apiGet(this, _url,
        onSuccess: (jsonMap) {
          final List<Post> newPosts = List();
          String newUrl;

          if (jsonMap.containsKey('posts')) {
            decodePostsAndTheirReplies(jsonMap['posts'])
                .where((p) => !p.postIsFirstPost)
                .forEach((post) => newPosts.add(post));
          }

          if (jsonMap.containsKey('links')) {
            final links = Links.fromJson(jsonMap['links']);
            newUrl = links.next;
          }

          setState(() {
            posts.addAll(newPosts);
            _url = newUrl;
          });
        },
        onComplete: () => setState(() => _isFetching = false));
  }

  Widget _buildFirstPost() {
    _firstPost ??= _FirstPostWidget(widget.thread);
    return _firstPost;
  }

  Widget _buildPostRoot(Post post) => _ParentPostInheritedWidget(
        parentPost: post,
        child: PostListInheritedWidget(
          child: buildRow(
            context,
            buildPosterCircleAvatar(post.links.posterAvatar),
            box: <Widget>[
              buildPosterInfo(
                context,
                post.posterUsername,
                date: post.postCreateDate,
              ),
              TinhteHtmlWidget(post.postBodyHtml),
              _PostAttachmentsWidget.forPost(post),
            ],
            footer: <Widget>[
              _PostActionsWidget(post),
              _PostRepliesWidget(post),
            ],
          ),
        ),
      );
}

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
  State<StatefulWidget> createState() =>
      _PostListWidgetState(this.path, thread?.firstPost);
}

class _PostListWidgetState extends State<_PostListWidget> {
  final List<Post> posts = List();

  Post _firstPost;
  bool _isFetching = false;
  VoidCallback _removeListener;
  String _url;

  _PostListWidgetState(this._url, this._firstPost);

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
            i == 0 ? _buildPostFirst(_firstPost) : _buildPostRoot(posts[i - 1]),
        itemCount: 1 + posts.length,
      );

  void fetch() async {
    if (_isFetching || _url?.isNotEmpty != true) return;
    setState(() => _isFetching = true);

    Post newFirstPost;
    List<Post> newPosts = List();
    String newUrl;

    final api = ApiInheritedWidget.of(context).api;
    final json = await api.getJson(_url);
    final jsonMap = json as Map<String, dynamic>;
    if (jsonMap.containsKey('posts')) {
      final decodedPosts = decodePostsAndTheirReplies(json['posts']);
      decodedPosts.forEach((post) {
        if (post.postIsFirstPost) {
          newFirstPost = post;
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
      posts.addAll(newPosts);
      if (newFirstPost != null) _firstPost = newFirstPost;

      _isFetching = false;
      _url = newUrl;
    });
  }

  Widget _buildPostFirst(Post post) => Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: kPaddingHorizontal, vertical: 10.0),
              child: Text(
                widget.thread?.threadTitle ?? '',
                maxLines: null,
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TinhteHtmlWidget(post?.postBodyHtml, isFirstPost: true),
            _PostActionsWidget(post),
          ],
        ),
      );

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
            ],
            footer: <Widget>[
              _PostActionsWidget(post),
              _PostRepliesWidget(post),
            ],
          ),
        ),
      );
}

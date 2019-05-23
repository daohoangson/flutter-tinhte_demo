part of '../posts.dart';

class _PostActionsWidget extends StatefulWidget {
  final Post post;
  final bool showPostCreateDate;

  _PostActionsWidget(
    this.post, {
    Key key,
    this.showPostCreateDate = true,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PostActionsWidgetState();
}

class _PostActionsWidgetState extends State<_PostActionsWidget> {
  bool _isShowingEditor = false;
  bool _isLiking = false;

  Post get post => widget.post;
  bool get postIsLiked => post.postIsLiked == true;
  int get postLikeCount => post.postLikeCount ?? 0;

  set postIsLiked(bool value) => post?.postIsLiked = value;
  set postLikeCount(int value) => post?.postLikeCount = value;

  @override
  Widget build(BuildContext context) {
    final buttons = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        buildButton(
          context,
          postIsLiked ? 'Unlike' : 'Like',
          count: postLikeCount,
          onTap: _isLiking ? null : (postIsLiked ? _unlikePost : _likePost),
        ),
        buildButton(
          context,
          _isShowingEditor ? 'Cancel' : 'Reply',
          onTap: () => setState(() => _isShowingEditor = !_isShowingEditor),
        ),
        widget.showPostCreateDate
            ? buildButton(
                context,
                formatTimestamp(post.postCreateDate),
              )
            : Container(height: 0.0, width: 0.0),
      ],
    );

    final thread = Provider.of<Thread>(context);
    if (!_isShowingEditor || thread == null) return buttons;

    Post parentPost;
    try {
      parentPost = Provider.of<Post>(context);
    } on ProviderNotFoundError catch (_) {
      // ignore this error, it will happen when replying to first post
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        buttons,
        PostEditor(
          thread.threadId,
          callback: (post) {
            Provider.of<NewPostStream>(context, listen: false)._add(post);
            setState(() => _isShowingEditor = false);
          },
          parentPostId: parentPost?.postId,
        )
      ],
    );
  }

  _likePost() => prepareForApiAction(this, () {
        if (_isLiking) return;
        setState(() => _isLiking = true);

        apiPost(this, widget.post.links.likes,
            onSuccess: (_) => setState(() {
                  postIsLiked = true;
                  postLikeCount++;
                }),
            onComplete: () => setState(() => _isLiking = false));
      });

  _unlikePost() => prepareForApiAction(this, () {
        if (_isLiking) return;
        setState(() => _isLiking = true);

        apiDelete(this, widget.post.links.likes,
            onSuccess: (_) => setState(() {
                  postIsLiked = false;
                  if (postLikeCount > 0) postLikeCount--;
                }),
            onComplete: () => setState(() => _isLiking = false));
      });
}

class NewPostStream {
  // TODO: wait for https://github.com/dart-lang/linter/issues/1446
  // ignore: close_sinks
  final StreamController<Post> _controller = StreamController.broadcast();

  void _add(Post post) => _controller.sink.add(post);

  StreamSubscription<Post> listen(
    void onData(Post post), {
    Function onError,
    void onDone(),
    bool cancelOnError,
  }) =>
      _controller.stream.listen(
        onData,
        onError: onError,
        onDone: onDone,
        cancelOnError: cancelOnError,
      );

  static Provider<NewPostStream> buildProvider({Widget child}) =>
      Provider<NewPostStream>(
        builder: (_) => NewPostStream(),
        child: child,
        dispose: (_, stream) => stream._controller.close(),
      );
}

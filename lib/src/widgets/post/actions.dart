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

    if (!_isShowingEditor) return buttons;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        buttons,
        PostEditor(
          _ThreadInheritedWidget.of(context).thread.threadId,
          callback: (post) {
            PostListInheritedWidget.of(context)?.notifyListeners(post);
            setState(() => _isShowingEditor = false);
          },
          parentPostId:
              _ParentPostInheritedWidget.of(context)?.parentPost?.postId,
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

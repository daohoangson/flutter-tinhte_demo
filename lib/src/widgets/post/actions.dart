part of '../posts.dart';

class _PostActionsWidget extends StatefulWidget {
  final Post post;

  _PostActionsWidget(this.post, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PostActionsWidgetState();
}

class _PostActionsWidgetState extends State<_PostActionsWidget> {
  bool isShowingEditor = false;
  bool isLiking = false;
  
  Post get post => widget.post;
  bool get postIsLiked => post?.postIsLiked == true;
  int get postLikeCount => post?.postLikeCount ?? 0;

  set postIsLiked(bool value) => post?.postIsLiked = value;
  set postLikeCount(int value) => post?.postLikeCount = value;

  @override
  Widget build(BuildContext context) {
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        buildButton(
          context,
          postIsLiked ? 'Unlike' : 'Like',
          count: postLikeCount,
          onTap: isLiking ? null : (postIsLiked ? _unlikePost : _likePost),
        ),
        buildButton(
          context,
          'Reply',
          onTap: () => setState(() => isShowingEditor = true),
        ),
      ],
    );

    if (!isShowingEditor) return row;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        row,
        PostEditor(
          _ThreadInheritedWidget.of(context).thread,
          onDismissed: () => setState(() => isShowingEditor = false),
          parentPost: _ParentPostInheritedWidget.of(context)?.parentPost,
        )
      ],
    );
  }

  _likePost() => prepareForApiAction(this, () {
        if (isLiking) return;
        setState(() => isLiking = true);

        apiPost(this, widget.post.links.likes,
            onSuccess: (_) => setState(() {
                  postIsLiked = true;
                  postLikeCount++;
                }),
            onComplete: () => setState(() => isLiking = false));
      });

  _unlikePost() => prepareForApiAction(this, () {
        if (isLiking) return;
        setState(() => isLiking = true);

        apiDelete(this, widget.post.links.likes,
            onSuccess: (_) => setState(() {
                  postIsLiked = false;
                  if (postLikeCount > 0) postLikeCount--;
                }),
            onComplete: () => setState(() => isLiking = false));
      });
}

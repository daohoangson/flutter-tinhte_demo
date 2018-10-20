part of '../posts.dart';

class _PostActionsWidget extends StatefulWidget {
  final Post post;

  _PostActionsWidget(this.post, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PostActionsWidgetState();
}

class _PostActionsWidgetState extends State<_PostActionsWidget> {
  bool isShowingEditor = false;
  bool postIsLiked;
  int postLikeCount;

  @override
  void initState() {
    super.initState();

    postIsLiked = widget.post.postIsLiked == true;
    postLikeCount = widget.post.postLikeCount ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        buildButton(
          context,
          postIsLiked ? 'Unlike' : 'Like',
          () => postIsLiked ? _unlikePost() : _likePost(),
          count: postLikeCount,
        ),
        buildButton(
          context,
          'Reply',
          () => setState(() => isShowingEditor = true),
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

part of '../posts.dart';

Widget _buildReplyToPadding(Widget child, int depth) =>
    depth == null || depth == 0
        ? child
        : Padding(
            child: child,
            padding: EdgeInsets.only(
              left: 2 * kPaddingHorizontal +
                  kAvatarRootRadius +
                  (depth > 1
                      ? (depth - 1) *
                          (2 * kPaddingHorizontal + kAvatarReplyToRadius)
                      : 0),
            ),
          );

class _PostWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final post = Provider.of<Post>(context);
    final isPostReply = post.postReplyTo != null;
    final attachments = _PostAttachmentsWidget.forPost(post);

    Widget built = buildPostRow(
      context,
      buildPosterCircleAvatar(
        post.links.posterAvatar,
        isPostReply: isPostReply,
      ),
      box: <Widget>[
        buildPosterInfo(
          context,
          post.posterUsername,
          userId: post.posterUserId,
          userHasVerifiedBadge: post.posterHasVerifiedBadge,
          userRank: post.posterRank?.rankName,
        ),
        _PostBodyWidget(needBottomMargin: attachments != null),
        attachments ?? widget0,
      ],
      footer: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: kPaddingHorizontal),
          child: _PostActionsWidget(),
        ),
      ],
    );

    built = NewPostStream.buildProvider(child: built);

    built = _buildReplyToPadding(built, post.postReplyDepth);

    return built;
  }
}

class _PostReplyHiddenWidget extends StatefulWidget {
  final int depth;
  final PostReply postReply;
  final int superListIndex;

  _PostReplyHiddenWidget(
    this.depth,
    this.postReply,
    this.superListIndex, {
    Key key,
  })  : assert(depth != null),
        assert(superListIndex != null),
        assert(postReply != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() => _PostReplyHiddenWidgetState();
}

class _PostReplyHiddenWidgetState extends State<_PostReplyHiddenWidget> {
  bool _isFetching = false;

  @override
  Widget build(BuildContext context) {
    Widget built = _isFetching
        ? _buildText(context, 'Loading...')
        : GestureDetector(
            child: _buildText(
              context,
              "Tap to load ${widget.postReply.postReplyCount} hidden replies...",
            ),
            onTap: fetch,
          );

    built = Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 7.5,
        horizontal: kPaddingHorizontal,
      ),
      child: built,
    );

    built = _buildReplyToPadding(built, widget.depth);

    return built;
  }

  void fetch() {
    if (_isFetching) return;
    setState(() => _isFetching = true);

    return apiGet(
      ApiCaller.stateful(this),
      widget.postReply.link,
      onSuccess: (jsonMap) {
        final sls = Provider.of<SuperListState<_PostListItem>>(context);
        final items = jsonMap.containsKey('replies')
            ? decodePostsAndTheirReplies(
                jsonMap['replies'],
                parentPostId: widget.postReply.postReplyTo,
              )
            : <_PostListItem>[];
        sls.itemsReplace(widget.superListIndex, items);
      },
      onComplete: () => setState(() => _isFetching = false),
    );
  }

  Widget _buildText(BuildContext context, String data) => Text(
        data,
        style: Theme.of(context).textTheme.caption,
      );
}

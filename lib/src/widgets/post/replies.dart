part of '../posts.dart';

class _PostWidget extends StatelessWidget {
  final Post post;

  const _PostWidget({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (post.userIsIgnored == true) return widget0;

    final isPostReply = post.postReplyTo != null;
    final attachments = _PostAttachmentsWidget.forPost(post);
    final stickers = _PostStickersWidget.forPost(post);

    Widget built = buildPostRow(
      context,
      buildPosterCircleAvatar(
        post.links?.posterAvatar,
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
        _PostBodyWidget(post: post),
        if (attachments != null) attachments,
        if (stickers != null) stickers,
      ],
      footer: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: kPaddingHorizontal),
          child: _PostActionsWidget(post: post),
        ),
      ],
    );

    built = _buildReplyToPadding(built, post.postReplyDepth ?? 0);

    return built;
  }
}

class _PostReplyHiddenWidget extends StatefulWidget {
  final PostReply postReply;
  final int superListIndex;

  _PostReplyHiddenWidget(
    this.postReply,
    this.superListIndex, {
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PostReplyHiddenWidgetState();
}

class _PostReplyHiddenWidgetState extends State<_PostReplyHiddenWidget> {
  bool _isFetching = false;

  @override
  Widget build(BuildContext context) {
    Widget built = _isFetching
        ? _buildText(context, l(context).loadingEllipsis)
        : GestureDetector(
            child: _buildText(
              context,
              l(context).postLoadXHidden(
                  formatNumber(widget.postReply.postReplyCount ?? 0)),
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

    final postReplyDepth = widget.postReply.postReplyDepth;
    if (postReplyDepth != null) {
      built = _buildReplyToPadding(built, postReplyDepth + 1);
    }

    // this is required to go full width
    built = Row(children: <Widget>[built]);

    return built;
  }

  void fetch() {
    if (_isFetching) return;
    setState(() => _isFetching = true);

    return apiGet(
      ApiCaller.stateful(this),
      widget.postReply.link!,
      onSuccess: (jsonMap) {
        final sls = context.read<SuperListState<_PostListItem>>();
        final parentPostValue = jsonMap['parent_post'];
        final parentPost = parentPostValue is Map ? parentPostValue : {};
        final repliesValue = jsonMap['replies'];
        if (parentPost['post_id'] == widget.postReply.postReplyTo &&
            repliesValue is Iterable) {
          final items =
              decodePostsAndTheirReplies([parentPost, ...repliesValue])
                  .where((item) => item.postId != widget.postReply.postReplyTo)
                  .toList();

          if (items.isNotEmpty &&
              items.last.postReply?.postReplyCount != null) {
            // ignore the last "load more"
            items.removeLast();
          }

          sls.itemsReplace(widget.superListIndex, items);
        } else {
          sls.itemsReplace(widget.superListIndex, []);
        }
      },
      onComplete: () => setState(() => _isFetching = false),
    );
  }

  Widget _buildText(BuildContext context, String data) => Text(
        data,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.caption,
      );
}

Widget _buildReplyToPadding(Widget child, int depth) => depth == 0
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

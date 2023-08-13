part of '../threads.dart';

const _kThreadWidgetPadding = 10.0;
const _kThreadWidgetSpacing = SizedBox(height: _kThreadWidgetPadding);

class ThreadWidget extends StatelessWidget {
  final Thread thread;
  final UserFeedData? feedData;

  const ThreadWidget(
    this.thread, {
    Key? key,
    this.feedData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (thread.userIsIgnored == true) return const SizedBox.shrink();

    final firstPost = thread.firstPost;
    final firstPostIsBackground =
        firstPost != null ? isBackgroundPost(firstPost) : false;
    final threadIsTinhteFact = isTinhteFact(thread);
    final isCustomPost = firstPostIsBackground || threadIsTinhteFact;
    final isThreadTitleRedundant =
        isCustomPost || thread.isThreadTitleRedundant;

    final children = <Widget>[
      _kThreadWidgetSpacing,
      _buildTextPadding(_buildInfo(context)),
    ];

    if (!isThreadTitleRedundant) {
      children.addAll([
        _kThreadWidgetSpacing,
        _buildTextPadding(_buildTitle(context)),
      ]);
    }

    children.addAll([
      _kThreadWidgetSpacing,
      _buildTextPadding(
        firstPost != null && firstPostIsBackground
            ? BackgroundPost(firstPost)
            : (threadIsTinhteFact ? TinhteFact(thread) : _buildBody(context)),
      ),
    ]);

    final image = _buildImage();
    if (!isCustomPost && image != null) {
      children.addAll([
        _kThreadWidgetSpacing,
        image,
      ]);
    }

    children.add(_ThreadWidgetActions(thread));

    Widget built = _buildCard(context, children);

    if (thread.threadIsSticky == true) {
      built = _buildBanner(context, built);
    }

    return built;
  }

  Widget _buildBanner(BuildContext context, Widget child) => ClipRect(
        child: Banner(
          location: BannerLocation.topEnd,
          message: l(context).threadStickyBanner,
          child: child,
        ),
      );

  Widget _buildBody(BuildContext context) => Text(
        thread.firstPost?.postBodyPlainText ?? '',
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      );

  Widget _buildCard(BuildContext context, List<Widget> children) => Card(
        margin: const EdgeInsets.only(bottom: _kThreadWidgetPadding),
        child: GestureDetector(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ThreadViewScreen(thread)),
          ),
        ),
      );

  Widget? _buildImage() {
    final image = config.threadWidgetShowCoverImageOnly
        ? thread.threadImageOriginal
        : thread.threadImage;
    if (image == null ||
        (config.threadWidgetShowCoverImageOnly &&
            image.displayMode != 'cover')) {
      // skip rendering if there is no thread image
      // or app has been configured to show cover only and this one is not in cover mode
      return null;
    }

    final width = image.width;
    final height = image.height;
    if (width != null && height != null && height > width) {
      // skip rendering if image dimensions are available and this is a portrait
      return null;
    }

    return ThreadImageWidget.small(thread, image, useImageRatio: true);
  }

  Widget _buildInfo(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.titleMedium;

    return Row(
      children: <Widget>[
        _buildInfoAvatar(),
        const SizedBox(width: _kThreadWidgetPadding),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildInfoUsername(theme, style),
              const SizedBox(height: _kThreadWidgetPadding / 4),
              Text(
                formatTimestamp(context, thread.threadCreateDate),
                style: theme.textTheme.bodySmall,
                textScaleFactor: 1,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoAvatar() {
    final avatar = thread.links?.firstPosterAvatar;
    return CircleAvatar(
      backgroundImage:
          avatar != null ? CachedNetworkImageProvider(avatar) : null,
      radius: 20,
    );
  }

  Widget _buildInfoUsername(ThemeData theme, TextStyle? style) {
    final buffer = StringBuffer(thread.creatorUsername ?? '');
    final inlineSpans = <InlineSpan>[];

    if (thread.creatorHasVerifiedBadge == true) {
      buffer.write(' ');
      inlineSpans.add(WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Icon(
          FontAwesomeIcons.solidCircleCheck,
          color: theme.colorScheme.secondary,
          size: style?.fontSize,
        ),
      ));
    }

    return RichText(
      text: TextSpan(
        children: inlineSpans,
        style: style?.copyWith(fontWeight: FontWeight.bold),
        text: buffer.toString(),
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildTextPadding(Widget child) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: _kThreadWidgetPadding),
        child: child,
      );

  Widget _buildTitle(BuildContext context) => Text(
        thread.threadTitle ?? '',
        style: const TextStyle(fontWeight: FontWeight.bold),
      );
}

class _ThreadWidgetActions extends StatefulWidget {
  final Thread thread;

  const _ThreadWidgetActions(this.thread, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ThreadWidgetActionsState();
}

class _ThreadWidgetActionsState extends State<_ThreadWidgetActions> {
  var _isLiking = false;

  Post? get post => thread.firstPost;
  Thread get thread => widget.thread;

  @override
  Widget build(BuildContext context) =>
      AnimatedBuilder(animation: thread, builder: _builder);

  Widget _builder(BuildContext context, Widget? _) {
    final permalink = thread.links?.permalink ?? '';
    return Column(
      children: <Widget>[
        InkWell(
          child: Padding(
            padding: const EdgeInsets.all(_kThreadWidgetPadding),
            child: _buildCounters(context),
          ),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ThreadViewScreen(thread)),
          ),
        ),
        const Divider(
          height: 0,
          indent: _kThreadWidgetPadding,
          endIndent: _kThreadWidgetPadding,
        ),
        IconTheme(
          data: Theme.of(context).iconTheme.copyWith(size: 20),
          child: Row(
            children: <Widget>[
              Expanded(child: _buildButtonLike()),
              Expanded(
                child: TextButton.icon(
                  icon: const Icon(FontAwesomeIcons.message),
                  label: Text(l(context).postReply),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ThreadViewScreen(
                        thread,
                        enablePostEditor: true,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: TextButton.icon(
                  icon: const Icon(FontAwesomeIcons.shareNodes),
                  label: Text(l(context).share),
                  onPressed: permalink.isNotEmpty
                      ? () => Share.share(permalink)
                      : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildButtonLike() {
    final post = this.post;
    if (post == null) return const SizedBox.shrink();

    final linkLikes = post.links?.likes ?? '';

    return AnimatedBuilder(
      animation: post,
      builder: (_, __) => TextButton.icon(
        icon: post.postIsLiked
            ? const Icon(FontAwesomeIcons.solidHeart)
            : const Icon(FontAwesomeIcons.heart),
        label: post.postIsLiked
            ? Text(l(context).postUnlike)
            : Text(l(context).postLike),
        onPressed: _isLiking
            ? null
            : linkLikes.isEmpty
                ? null
                : post.postIsLiked
                    ? _unlikePost
                    : _likePost,
      ),
    );
  }

  Widget? _buildCounterLike(Post post, TextStyle? textStyle) {
    final postLikeCount = post.postLikeCount ?? 0;
    if (postLikeCount == 0) return null;

    final inlineSpans = <InlineSpan>[
      WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Icon(
          post.postIsLiked
              ? FontAwesomeIcons.solidHeart
              : FontAwesomeIcons.heart,
          color: textStyle?.color,
          size: textStyle?.fontSize,
        ),
      ),
      TextSpan(
        text: " ${formatNumber(postLikeCount)}",
        style: textStyle,
      ),
    ];

    return RichText(
      text: TextSpan(children: inlineSpans),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget? _buildCounterReply(TextStyle? textStyle) {
    final replyCount = (thread.threadPostCount ?? 1) - 1;

    return replyCount > 0
        ? Text(
            l(context).statsXReplies(replyCount),
            style: textStyle,
            textScaleFactor: 1,
          )
        : null;
  }

  Widget? _buildCounters(BuildContext context) {
    final post = this.post;
    if (post == null) return null;

    final textStyle = Theme.of(context).textTheme.bodySmall;
    return AnimatedBuilder(
      animation: post,
      builder: (_, __) {
        final like = _buildCounterLike(post, textStyle);
        final reply = _buildCounterReply(textStyle);
        if (like == null && reply == null) {
          return const SizedBox.shrink();
        }

        final children = <Widget>[];
        if (like != null) children.add(like);
        if (reply != null) children.add(reply);

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: children,
        );
      },
    );
  }

  void _likePost() => prepareForApiAction(context, () {
        if (_isLiking) return;

        final linkLikes = post?.links?.likes ?? '';
        if (linkLikes.isEmpty) return;

        setState(() => _isLiking = true);

        apiPost(
          ApiCaller.stateful(this),
          linkLikes,
          onSuccess: (_) => post?.postIsLiked = true,
          onComplete: () => setState(() => _isLiking = false),
        );
      });

  void _unlikePost() => prepareForApiAction(context, () {
        if (_isLiking) return;

        final linkLikes = post?.links?.likes ?? '';
        if (linkLikes.isEmpty) return;

        setState(() => _isLiking = true);

        apiDelete(
          ApiCaller.stateful(this),
          linkLikes,
          onSuccess: (_) => post?.postIsLiked = false,
          onComplete: () => setState(() => _isLiking = false),
        );
      });
}

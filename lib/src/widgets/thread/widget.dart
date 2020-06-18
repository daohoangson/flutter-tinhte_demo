part of '../threads.dart';

const _kThreadWidgetPadding = 10.0;
const _kThreadWidgetSpacing = const SizedBox(height: _kThreadWidgetPadding);

class ThreadWidget extends StatelessWidget {
  final Thread thread;
  final UserFeedData feedData;

  ThreadWidget(
    this.thread, {
    Key key,
    this.feedData,
  })  : assert(thread != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final _isBackgroundPost = isBackgroundPost(thread.firstPost);
    final _isTinhteFact = isTinhteFact(thread);
    final _isCustomPost = _isBackgroundPost || _isTinhteFact;
    final _isThreadTitleRedundant =
        _isCustomPost || isThreadTitleRedundant(thread);

    final children = <Widget>[
      _kThreadWidgetSpacing,
      _buildTextPadding(_buildInfo(context)),
    ];

    if (!_isThreadTitleRedundant) {
      children.addAll([
        _kThreadWidgetSpacing,
        _buildTextPadding(_buildTitle(context)),
      ]);
    }

    children.addAll([
      _kThreadWidgetSpacing,
      _buildTextPadding(
        _isBackgroundPost
            ? BackgroundPost(thread.firstPost)
            : (_isTinhteFact ? TinhteFact(thread) : _buildBody(context)),
      ),
    ]);

    final image = _buildImage();
    if (!_isCustomPost && image != null) {
      children.addAll([
        _kThreadWidgetSpacing,
        image,
      ]);
    }

    children.add(_ThreadWidgetActions(thread));

    Widget built = _buildCard(context, children);

    final popupMenuButton =
        buildPopupMenuButtonForThread(context, thread, feedData);
    if (popupMenuButton != null) {
      built = _buildPopupMenu(built, popupMenuButton);
    } else {
      if (thread.threadIsSticky) built = _buildBanner(context, built);
    }

    return built;
  }

  Widget _buildBanner(BuildContext context, Widget child) => ClipRect(
        child: Banner(
          child: child,
          location: BannerLocation.topEnd,
          message: l(context).threadStickyBanner,
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
            children: children,
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ThreadViewScreen(thread)),
          ),
        ),
      );

  Widget _buildImage() {
    final image = thread.threadImage;
    if (image?.displayMode != 'cover' ||
        image.width == null ||
        image.height == null ||
        image.height > image.width) return null;

    return ThreadImageWidget(
      image: image,
      threadId: thread.threadId,
      useImageRatio: true,
    );
  }

  Widget _buildInfo(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.subtitle1;

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
                formatTimestamp(thread.threadCreateDate),
                style: theme.textTheme.caption,
                textScaleFactor: 1,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoAvatar() => CircleAvatar(
        backgroundImage: thread.links?.firstPosterAvatar != null
            ? CachedNetworkImageProvider(thread.links.firstPosterAvatar)
            : null,
        radius: 20,
      );

  Widget _buildInfoUsername(ThemeData theme, TextStyle style) {
    final buffer = StringBuffer(thread.creatorUsername ?? '');
    final inlineSpans = <InlineSpan>[];

    if (thread.creatorHasVerifiedBadge) {
      buffer.write(' ');
      inlineSpans.add(WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Icon(
          FontAwesomeIcons.solidCheckCircle,
          color: theme.accentColor,
          size: style.fontSize,
        ),
      ));
    }

    return RichText(
      text: TextSpan(
        children: inlineSpans,
        style: style.copyWith(fontWeight: FontWeight.bold),
        text: buffer.toString(),
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildPopupMenu(Widget child, PopupMenuButton popupMenuButton) =>
      Stack(
        children: <Widget>[
          child,
          Align(alignment: Alignment.topRight, child: popupMenuButton)
        ],
      );

  Widget _buildTextPadding(Widget child) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: _kThreadWidgetPadding),
        child: child,
      );

  Widget _buildTitle(BuildContext context) => Text(
        thread.threadTitle ?? '',
        style: TextStyle(fontWeight: FontWeight.bold),
      );
}

class _ThreadWidgetActions extends StatefulWidget {
  final Thread thread;

  _ThreadWidgetActions(this.thread, {Key key})
      : assert(thread != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() => _ThreadWidgetActionsState();
}

class _ThreadWidgetActionsState extends State<_ThreadWidgetActions> {
  var _isLiking = false;

  String get linkLikes => post?.links?.likes;
  String get linkPermalink => thread.links?.permalink;
  Post get post => thread.firstPost;
  bool get postIsLiked => post?.postIsLiked == true;
  int get postLikeCount => post?.postLikeCount ?? 0;
  Thread get thread => widget.thread;
  int get threadReplyCount => (thread.threadPostCount ?? 1) - 1;

  set postIsLiked(bool value) => post?.postIsLiked = value;
  set postLikeCount(int value) => post?.postLikeCount = value;

  @override
  Widget build(BuildContext context) => Column(children: <Widget>[
        InkWell(
          child: Padding(
            padding: const EdgeInsets.all(_kThreadWidgetPadding),
            child: _buildCounters(context),
          ),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ThreadViewScreen(thread)),
          ),
        ),
        Divider(
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
                child: FlatButton.icon(
                  icon: Icon(FontAwesomeIcons.commentAlt),
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
                child: FlatButton.icon(
                  icon: Icon(FontAwesomeIcons.shareAlt),
                  label: Text(l(context).share),
                  onPressed: linkPermalink?.isNotEmpty == true
                      ? () => Share.share(linkPermalink)
                      : null,
                ),
              ),
            ],
          ),
        ),
      ]);

  Widget _buildButtonLike() => FlatButton.icon(
        icon: postIsLiked
            ? const Icon(FontAwesomeIcons.solidHeart)
            : const Icon(FontAwesomeIcons.heart),
        label: postIsLiked
            ? Text(l(context).postUnlike)
            : Text(l(context).postLike),
        onPressed: _isLiking
            ? null
            : linkLikes?.isNotEmpty != true
                ? null
                : postIsLiked ? _unlikePost : _likePost,
      );

  Widget _buildCounterLike(TextStyle textStyle) {
    if (postLikeCount == 0) return null;

    final inlineSpans = <InlineSpan>[
      WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Icon(
          postIsLiked ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
          color: textStyle.color,
          size: textStyle.fontSize,
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

  Widget _buildCounterReply(TextStyle textStyle) => threadReplyCount > 0
      ? Text(
          l(context).statsXReplies(threadReplyCount),
          style: textStyle,
          textScaleFactor: 1,
        )
      : null;

  Widget _buildCounters(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.caption;
    final like = _buildCounterLike(textStyle);
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
  }

  void _likePost() => prepareForApiAction(context, () {
        if (_isLiking) return;
        setState(() => _isLiking = true);

        apiPost(
          ApiCaller.stateful(this),
          linkLikes,
          onSuccess: (_) => setState(() {
            postIsLiked = true;
            postLikeCount++;
          }),
          onComplete: () => setState(() => _isLiking = false),
        );
      });

  void _unlikePost() => prepareForApiAction(context, () {
        if (_isLiking) return;
        setState(() => _isLiking = true);

        apiDelete(
          ApiCaller.stateful(this),
          linkLikes,
          onSuccess: (_) => setState(() {
            postIsLiked = false;
            if (postLikeCount > 0) postLikeCount--;
          }),
          onComplete: () => setState(() => _isLiking = false),
        );
      });
}

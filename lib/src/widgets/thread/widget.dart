part of '../threads.dart';

const _kPaddingHorizontal = EdgeInsets.symmetric(horizontal: 10);

class ThreadWidget extends StatelessWidget {
  final Thread thread;

  ThreadWidget(this.thread, {Key key})
      : assert(thread != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      const SizedBox(height: 10),
      _buildTextPadding(_buildInfo(context)),
      const SizedBox(height: 10),
    ];

    if (!isThreadTitleRedundant(thread)) {
      children.addAll([
        _buildTextPadding(_buildTitle(context)),
        const SizedBox(height: 10),
      ]);
    }

    children.addAll([
      _buildTextPadding(_buildBody(context)),
      const SizedBox(height: 10),
    ]);

    final image = _buildImage();
    if (image != null) {
      children.addAll([
        image,
        const SizedBox(height: 10),
      ]);
    }

    children.add(_ThreadWidgetActions(thread));

    return _buildCard(context, children);
  }

  Widget _buildBody(BuildContext context) => Text(
        thread.firstPost.postBodyPlainText,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      );

  Widget _buildCard(BuildContext context, List<Widget> children) => Card(
        margin: const EdgeInsets.only(bottom: 10),
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

  Widget _buildImage() => thread?.threadImage != null
      ? ThreadImageWidget(
          image: thread?.threadImage,
          threadId: thread?.threadId,
          useImageRatio: true,
        )
      : null;

  Widget _buildInfo(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.subhead;

    return Row(
      children: <Widget>[
        _buildInfoAvatar(),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildInfoUsername(style),
              const SizedBox(height: 3),
              RichText(
                text: TextSpan(
                  text: formatTimestamp(thread.threadCreateDate),
                  style: theme.textTheme.caption,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoAvatar() => CircleAvatar(
        backgroundImage: thread?.links?.firstPosterAvatar != null
            ? CachedNetworkImageProvider(thread.links.firstPosterAvatar)
            : null,
        radius: 20,
      );

  Widget _buildInfoUsername(TextStyle style) {
    final children = <Widget>[
      RichText(
        text: TextSpan(
          style: style.copyWith(fontWeight: FontWeight.bold),
          text: thread?.creatorUsername ?? '■ ●● ▲▲▲',
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    ];

    if (thread?.creatorHasVerifiedBadge == true) {
      children.add(Icon(
        FontAwesomeIcons.solidCheckCircle,
        color: kColorUserVerifiedBadge,
        size: style.fontSize,
      ));
    }

    return Wrap(
      children: children,
      spacing: 5,
    );
  }

  Widget _buildTextPadding(Widget child) =>
      Padding(padding: _kPaddingHorizontal, child: child);

  Widget _buildTitle(BuildContext context) => Text(
        thread?.threadTitle ?? '▲  □■   ○●○    ▼◁▲▷',
        style: TextStyle(fontWeight: FontWeight.bold),
      );
}

class _ThreadWidgetActions extends StatefulWidget {
  final Thread thread;

  _ThreadWidgetActions(this.thread, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ThreadWidgetActionsState();
}

class _ThreadWidgetActionsState extends State<_ThreadWidgetActions> {
  var _isLiking = false;

  String get linkLikes => post?.links?.likes;
  String get linkPermalink => thread?.links?.permalink;
  Post get post => thread?.firstPost;
  bool get postIsLiked => post?.postIsLiked == true;
  int get postLikeCount => post?.postLikeCount ?? 0;
  Thread get thread => widget.thread;
  int get threadReplyCount => (thread?.threadPostCount ?? 1) - 1;

  set postIsLiked(bool value) => post?.postIsLiked = value;
  set postLikeCount(int value) => post?.postLikeCount = value;

  @override
  Widget build(BuildContext context) => Column(children: <Widget>[
        DefaultTextStyle(
          style: Theme.of(context).textTheme.caption,
          child: Padding(
            padding: _kPaddingHorizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _buildCounterLike(),
                _buildCounterReply(),
              ],
            ),
          ),
        ),
        Divider(indent: 10),
        IconTheme(
          data: Theme.of(context).iconTheme.copyWith(size: 20),
          child: Row(
            children: <Widget>[
              Expanded(child: _buildButtonLike()),
              Expanded(
                child: FlatButton.icon(
                  icon: Icon(FontAwesomeIcons.commentAlt),
                  label: Text('Reply'),
                  onPressed: null,
                ),
              ),
              Expanded(
                child: FlatButton.icon(
                  icon: Icon(FontAwesomeIcons.shareAlt),
                  label: Text('Share'),
                  onPressed: linkPermalink?.isNotEmpty == true
                      ? () => Share.share(linkPermalink)
                      : null,
                ),
              ),
            ],
          ),
        ),
      ]);

  _buildButtonLike() => FlatButton.icon(
        icon: postIsLiked
            ? const Icon(FontAwesomeIcons.solidHeart)
            : const Icon(FontAwesomeIcons.heart),
        label: postIsLiked ? const Text('Unlike') : const Text('Like'),
        onPressed: _isLiking
            ? null
            : linkLikes?.isNotEmpty != true
                ? null
                : postIsLiked ? _unlikePost : _likePost,
      );

  _buildCounterLike() => postLikeCount > 0
      ? Row(
          children: <Widget>[
            Icon(
              FontAwesomeIcons.solidHeart,
              color: Theme.of(context).accentColor,
              size: 13,
            ),
            Text(" ${formatNumber(postLikeCount)}"),
          ],
        )
      : SizedBox.shrink();

  _buildCounterReply() => threadReplyCount > 0
      ? Text("${formatNumber(threadReplyCount)} Replies")
      : SizedBox.shrink();

  _likePost() => prepareForApiAction(context, () {
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

  _unlikePost() => prepareForApiAction(context, () {
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

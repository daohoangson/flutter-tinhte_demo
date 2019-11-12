part of '../posts.dart';

Widget _buildPostWidget(Post post) =>
    ActionablePost.buildMultiProvider(post, _PostWidget());

class _PostWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<_PostWidget> {
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
        isPostReply ? SizedBox.shrink() : _PostRepliesWidget(),
      ],
    );

    if (!isPostReply) {
      built = NewPostStream.buildProvider(child: built);
    }

    return built;
  }
}

class _PostRepliesWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PostRepliesWidgetState();
}

class _PostRepliesWidgetState extends State<_PostRepliesWidget> {
  final List<Post> newPosts = List();

  StreamSubscription _newPostSub;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_newPostSub != null) _newPostSub.cancel();
    _newPostSub = Provider.of<NewPostStream>(context)
        .listen((post) => setState(() => newPosts.insert(0, post)));
  }

  @override
  void deactivate() {
    if (_newPostSub != null) {
      _newPostSub.cancel();
      _newPostSub = null;
    }

    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    final parentPost = Provider.of<Post>(context);
    final postReplyCount = parentPost.postReplies?.length ?? 0;
    List<Widget> children = List(newPosts.length + postReplyCount);

    for (int i = 0; i < newPosts.length; i++) {
      children[i] = _buildPostWidget(newPosts[i]);
    }

    for (int j = 0; j < postReplyCount; j++) {
      final reply = parentPost.postReplies[j];
      children[newPosts.length + j] = reply.post != null
          ? _buildPostWidget(reply.post)
          : reply.link?.isNotEmpty == true
              ? _PostReplyHiddenWidget(parentPost, reply)
              : SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

class _PostReplyHiddenWidget extends StatefulWidget {
  final Post parentPost;
  final PostReply postReply;

  _PostReplyHiddenWidget(this.parentPost, this.postReply, {Key key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _PostReplyHiddenWidgetState();
}

class _PostReplyHiddenWidgetState extends State<_PostReplyHiddenWidget> {
  bool _hasFetched = false;
  List<Post> _posts;

  String get link => widget.postReply.link;
  int get parentPostId => widget.parentPost.postId;
  int get postReplyCount => widget.postReply.postReplyCount;

  @override
  Widget build(BuildContext context) {
    if (_posts == null) {
      if (_hasFetched) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            kPaddingHorizontal,
            0.0,
            kPaddingHorizontal,
            15.0,
          ),
          child: _buildText(context, 'Loading...'),
        );
      }

      return Padding(
        padding: const EdgeInsets.fromLTRB(
          kPaddingHorizontal,
          0.0,
          kPaddingHorizontal,
          15.0,
        ),
        child: GestureDetector(
          child: _buildText(
            context,
            "Tap to load $postReplyCount hidden replies...",
          ),
          onTap: fetch,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _posts.map((p) => _buildPostWidget(p)).toList(),
    );
  }

  void fetch() {
    if (_hasFetched) return;
    setState(() => _hasFetched = true);

    return apiGet(
      ApiCaller.stateful(this),
      link,
      onSuccess: (jsonMap) {
        if (!jsonMap.containsKey('replies')) {
          setState(() => _posts = List(0));
          return;
        }

        final posts = decodePostsAndTheirReplies(
          jsonMap['replies'],
          parentPostId: parentPostId,
        );
        setState(() => _posts = posts);
      },
    );
  }

  Widget _buildText(BuildContext context, String data) => Text(
        data,
        style: Theme.of(context).textTheme.caption,
      );
}

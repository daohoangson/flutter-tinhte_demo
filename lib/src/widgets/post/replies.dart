part of '../posts.dart';

Widget _buildPostReply(BuildContext context, Post post) => buildRow(
      context,
      buildPosterCircleAvatar(post.links.posterAvatar, isPostReply: true),
      box: <Widget>[
        buildPosterInfo(
          context,
          post.posterUsername,
          userRank: post.posterRank?.rankName,
        ),
        TinhteHtmlWidget(post.postBodyHtml),
        _PostAttachmentsWidget.forPost(post),
      ],
      footer: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: kPaddingHorizontal),
          child: _PostActionsWidget(post),
        ),
      ],
    );

class _PostRepliesWidget extends StatefulWidget {
  final Post parentPost;

  _PostRepliesWidget(this.parentPost, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PostRepliesWidgetState();
}

class _PostRepliesWidgetState extends State<_PostRepliesWidget> {
  final List<Post> newPosts = List();

  VoidCallback _removeListener;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_removeListener != null) _removeListener();
    _removeListener = PostListInheritedWidget.of(context)
        .addListener((post) => setState(() => newPosts.insert(0, post)));
  }

  @override
  void deactivate() {
    if (_removeListener != null) {
      _removeListener();
      _removeListener = null;
    }

    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    final postReplyCount = widget.parentPost?.postReplies?.length ?? 0;
    List<Widget> children = List(newPosts.length + postReplyCount);

    for (int i = 0; i < newPosts.length; i++) {
      children[i] = _buildPostReply(context, newPosts[i]);
    }

    for (int j = 0; j < postReplyCount; j++) {
      final reply = widget.parentPost.postReplies[j];
      children[newPosts.length + j] = reply.post != null
          ? _buildPostReply(context, reply.post)
          : reply.link?.isNotEmpty == true
              ? _PostReplyHiddenWidget(reply.link, reply.postReplyCount)
              : Container(height: 0.0, width: 0.0);
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
  final String link;
  final int postReplyCount;

  _PostReplyHiddenWidget(this.link, this.postReplyCount, {Key key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _PostReplyHiddenWidgetState();
}

class _PostReplyHiddenWidgetState extends State<_PostReplyHiddenWidget> {
  bool _hasFetched = false;
  List<Post> _posts;

  @override
  Widget build(BuildContext context) {
    if (_posts == null) {
      if (_hasFetched) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
              kPaddingHorizontal, 0.0, kPaddingHorizontal, 15.0),
          child: const Center(child: CircularProgressIndicator()),
        );
      }

      return Padding(
        padding: const EdgeInsets.fromLTRB(
            kPaddingHorizontal, 0.0, kPaddingHorizontal, 15.0),
        child: GestureDetector(
          child: Text(
            "Tap to load ${widget.postReplyCount} hidden replies...",
            style: Theme.of(context).textTheme.caption,
          ),
          onTap: fetch,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _posts.map((p) => _buildPostReply(context, p)).toList(),
    );
  }

  fetch() {
    if (_hasFetched || widget.link == null) return;
    setState(() => _hasFetched = true);

    apiGet(this, widget.link, onSuccess: (jsonMap) {
      if (!jsonMap.containsKey('replies')) {
        setState(() => _posts = List(0));
        return;
      }

      final posts = decodePostsAndTheirReplies(jsonMap['replies']);
      setState(() => _posts = posts);
    });
  }
}
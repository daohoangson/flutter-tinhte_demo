part of '../posts.dart';

Widget _buildPostReply(BuildContext context, Post post) => buildRow(
      context,
      buildPosterCircleAvatar(post.links.posterAvatar, isPostReply: true),
      box: <Widget>[
        buildPosterInfo(
          context,
          post.posterUsername,
          date: post.postCreateDate,
        ),
        TinhteHtmlWidget(post.postBodyHtml),
      ],
      footer: <Widget>[_PostActionsWidget(post)],
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
          padding: const EdgeInsets.symmetric(
              horizontal: kPaddingHorizontal, vertical: 5.0),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      return Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: kPaddingHorizontal, vertical: 5.0),
        child: GestureDetector(
          child: Text(
            "Tap to load ${widget.postReplyCount} hidden replies...",
            style: DefaultTextStyle.of(context).style.copyWith(
                  color: Theme.of(context).primaryColorLight,
                  fontSize: 12.0,
                ),
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

  void fetch() async {
    if (_hasFetched || widget.link == null) return;
    setState(() => _hasFetched = true);

    final api = ApiInheritedWidget.of(context).api;
    final json = await api.getJson(widget.link);
    final jsonMap = json as Map<String, dynamic>;
    if (!jsonMap.containsKey('replies')) {
      setState(() => _posts = List(0));
      return;
    }

    final decodedPosts = decodePostsAndTheirReplies(json['replies']);
    setState(() => _posts = decodedPosts);
  }
}

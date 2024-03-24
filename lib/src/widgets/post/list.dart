part of '../posts.dart';

const _kPageIndicatorHeight = 40.0;

class PostsWidget extends StatefulWidget {
  final Map? initialJson;
  final String? path;
  final Thread thread;

  const PostsWidget(
    this.thread, {
    this.initialJson,
    this.path,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => PostsState();
}

class PostsState extends State<PostsWidget> {
  final _slsKey = GlobalKey<SuperListState<_PostListItem>>();

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? _unreadController;

  @override
  void dispose() {
    _unreadController?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final firstPost = widget.thread.firstPost;

    return SuperListView<_PostListItem>(
      enableScrollToIndex: true,
      fetchPathInitial: widget.path,
      fetchOnSuccess: _fetchOnSuccess,
      initialItems: firstPost != null ? [_PostListItem.post(firstPost)] : null,
      initialJson: widget.initialJson,
      itemBuilder: _buildItem,
      key: _slsKey,
    );
  }

  void insertNewPost(Post post) {
    final sls = _slsKey.currentState;
    if (sls == null) return;

    final index = _PostListItem.indexOfNewPost(sls.items, post);
    sls.itemsInsert(index, _PostListItem.post(post));
  }

  Widget _buildItem(
    BuildContext context,
    SuperListState<_PostListItem> state,
    _PostListItem item,
  ) {
    final page = item.pageCurrent;
    if (page != null) {
      return _buildPageIndicator(context, state, page, item.pageTotal);
    }

    final post = item.post;
    if (post != null) {
      return post.postIsFirstPost == true
          ? _FirstPostWidget(post: post, thread: widget.thread)
          : _PostWidget(post: post);
    }

    final postReply = item.postReply;
    if (postReply != null && postReply.postReplyCount != null) {
      final superListIndex = state.indexOf(item);
      assert(superListIndex > -1);
      return _PostReplyHiddenWidget(postReply, superListIndex);
    }

    return const SizedBox.shrink();
  }

  Widget _buildPageIndicator(
    BuildContext context,
    SuperListState<_PostListItem> state,
    int page,
    int? total,
  ) {
    if (state.isFetching) {
      return Stack(children: <Widget>[
        const Divider(height: _kPageIndicatorHeight),
        _buildPageIndicatorText(context, l(context).loadingEllipsis),
      ]);
    }

    final children = <Widget>[
      const Divider(height: _kPageIndicatorHeight),
      _buildPageIndicatorText(
        context,
        total == null
            ? l(context).navPageX(page)
            : l(context).navXOfY(page, total),
      ),
    ];

    final fetchedPageMin = state.fetchedPageMin ?? page;
    if (page > fetchedPageMin) {
      if (page > 2) {
        children.add(_buildPageIndicatorText(
          context,
          l(context).navLowercasePrevious,
          alignment: Alignment.centerLeft,
          onTap: () => _scrollToPage(state, page - 1),
        ));
      }
    } else if (state.canFetchPrev) {
      children.add(_buildPageIndicatorText(
        context,
        l(context).navLowercasePrevious,
        alignment: Alignment.centerLeft,
        onTap: () => state.fetchPrev(),
      ));
    }

    final fetchedPageMax = state.fetchedPageMax ?? page;
    if (page < fetchedPageMax) {
      children.add(_buildPageIndicatorText(
        context,
        l(context).navLowercaseNext,
        alignment: Alignment.centerRight,
        onTap: () => _scrollToPage(state, page + 1),
      ));
    } else if (state.canFetchNext) {
      children.add(_buildPageIndicatorText(
        context,
        l(context).navLowercaseNext,
        alignment: Alignment.centerRight,
        onTap: () => state.fetchNext(scrollToRelativeIndex: 0),
      ));
    }

    return Stack(children: children);
  }

  Widget _buildPageIndicatorText(
    BuildContext context,
    String text, {
    Alignment alignment = Alignment.center,
    GestureTapCallback? onTap,
  }) =>
      Positioned.fill(
        child: Align(
          alignment: alignment,
          child: DecoratedBox(
            decoration: BoxDecoration(color: Theme.of(context).canvasColor),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text.rich(
                TextSpan(
                  text: text,
                  recognizer: onTap != null
                      ? (TapGestureRecognizer()..onTap = onTap)
                      : null,
                ),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
        ),
      );

  void _fetchOnSuccess(Map json, FetchContext<_PostListItem> fc) {
    if (!json.containsKey('posts')) return;

    final firstItemPostId =
        fc.state.items.isEmpty ? null : fc.state.items.first.post?.postId;
    final linksPage = fc.linksPage ?? 1;
    final pageOfPostIdValue = json['page_of_post_id'];
    final pageOfPostId = pageOfPostIdValue is int ? pageOfPostIdValue : null;

    if (firstItemPostId != null || linksPage != 1) {
      fc.items.add(_PostListItem.page(linksPage, fc.linksPages));
    }

    final items = _decodePostsAndTheirReplies(json['posts']);
    for (final item in items) {
      if (firstItemPostId != null && item.postId == firstItemPostId) continue;

      if (firstItemPostId == null && linksPage == 1 && fc.items.length == 1) {
        fc.items.add(_PostListItem.page(linksPage, fc.linksPages));
      }

      if (pageOfPostId != null && item.postId == pageOfPostId) {
        fc.scrollToRelativeIndex = fc.items.length;
      }

      fc.items.add(item);
    }

    if (json.containsKey('thread')) {
      final freshThread = Thread.fromJson(json['thread']);
      final postsUnread = freshThread.links?.postsUnread;

      if (fc.id == FetchContextId.fetchInitial && postsUnread != null) {
        WidgetsBinding.instance.addPostFrameCallback(
            (_) => _showSnackBarUnread(fc.state, postsUnread));
      }
    }
  }

  Future<void> _showSnackBarUnread(
      SuperListState<_PostListItem> sls, String postsUnread) async {
    final controller =
        _unreadController = ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      action: SnackBarAction(
        label: l(context).postGoUnreadYes,
        onPressed: () => sls.fetch(
          clearItems: true,
          fc: FetchContext<_PostListItem>(
            path: postsUnread,
            state: sls,
          ),
        ),
      ),
      content: Text(l(context).postGoUnreadQuestion),
      duration: const Duration(seconds: 10),
    ));

    await controller.closed;
    if (identical(_unreadController, controller)) {
      _unreadController = null;
    }
  }

  void _scrollToPage(SuperListState<_PostListItem> state, int page) {
    var i = -1;
    for (final item in state.items) {
      i++;
      if (item.pageCurrent != page) continue;

      state.scrollToIndex(i, preferPosition: AutoScrollPosition.begin);
      return;
    }
  }
}

class _PostListItem {
  int? pageCurrent;
  int? pageTotal;
  Post? post;
  PostReply? postReply;

  _PostListItem.post(Post this.post);

  _PostListItem.postReply(PostReply this.postReply);

  _PostListItem.page(int this.pageCurrent, this.pageTotal);

  int? get postId => post?.postId ?? postReply?.postId;

  static int indexOfNewPost(Iterable<_PostListItem> items, Post post) {
    final depth = post.postReplyDepth ?? 0;
    final parentPostId = post.postReplyTo ?? 0;

    int i = -1;
    bool found = false;
    for (final item in items) {
      i++;
      if (!found) {
        if (item.postId == parentPostId) {
          found = true;
        }
      } else {
        final itemPost = item.post;
        if (itemPost == null) continue;

        final itemDepth = itemPost.postReplyDepth ?? 0;
        if (itemDepth < depth) return i;
      }
    }

    return items.length;
  }
}

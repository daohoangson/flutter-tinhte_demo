part of '../posts.dart';

const _kPageIndicatorHeight = 40.0;

class PostsWidget extends StatefulWidget {
  final Map initialJson;
  final String path;
  final Thread thread;

  PostsWidget(
    this.thread, {
    this.initialJson,
    Key key,
    this.path,
  })  : assert(thread != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() => PostsState();
}

class PostsState extends State<PostsWidget> {
  final _slsKey = GlobalKey<SuperListState<_PostListItem>>();

  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: [
          ChangeNotifierProvider<Thread>.value(value: widget.thread),
          ThreadNavigationWidget.buildProvider(),
        ],
        child: SuperListView<_PostListItem>(
          enableScrollToIndex: true,
          fetchPathInitial: widget.path,
          fetchOnSuccess: _fetchOnSuccess,
          initialItems: widget.thread.firstPost != null
              ? [_PostListItem.post(widget.thread.firstPost)]
              : null,
          initialJson: widget.initialJson,
          itemBuilder: _buildItem,
          key: _slsKey,
        ),
      );

  void insertNewPost(Post post) {
    final sls = _slsKey.currentState;
    if (sls == null) return;

    final index = _PostListItem.indexOfNewPost(sls.items, post);
    sls.itemsInsert(index, _PostListItem.post(post));
  }

  Widget _buildItem(
    BuildContext context,
    SuperListState state,
    _PostListItem item,
  ) {
    if (item.pageCurrent != null)
      return _buildPageIndicator(context, state, item);

    final post = item.post;
    if (post != null) {
      return ChangeNotifierProvider<Post>.value(
        child: post.postIsFirstPost ? _FirstPostWidget() : _PostWidget(),
        value: post,
      );
    }

    final postReply = item.postReply;
    if (postReply?.postReplyCount != null) {
      final superListIndex = state.indexOf(item);
      assert(superListIndex > -1);
      return _PostReplyHiddenWidget(
        postReply,
        superListIndex,
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildPageIndicator(
    BuildContext context,
    SuperListState state,
    _PostListItem item,
  ) {
    final page = item.pageCurrent;
    final total = item.pageTotal;

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

    if (page > state.fetchedPageMin) {
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

    if (page < state.fetchedPageMax) {
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
    GestureTapCallback onTap,
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
                style: Theme.of(context).textTheme.caption,
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
    final pageOfPostId = json.containsKey('page_of_post_id')
        ? json['page_of_post_id'] as int
        : null;

    if (firstItemPostId != null || linksPage != 1) {
      fc.items.add(_PostListItem.page(linksPage, fc.linksPages));
    }

    final items = decodePostsAndTheirReplies(json['posts']);
    for (final item in items) {
      if (firstItemPostId != null && item.postId == firstItemPostId) continue;

      if (firstItemPostId == null && linksPage == 1 && fc.items.length == 1) {
        fc.items.add(_PostListItem.page(linksPage, fc.linksPages));
      }

      if (pageOfPostId != null && item.postId == pageOfPostId)
        fc.scrollToRelativeIndex = fc.items.length;

      fc.items.add(item);
    }

    if (json.containsKey('thread')) {
      widget.thread.update(json['thread']);

      if (fc.id == FetchContextId.FetchInitial &&
          widget.thread.links?.postsUnread != null)
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _showSnackBarUnread(fc.state));
    }
  }

  void _showSnackBarUnread(SuperListState<_PostListItem> sls) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        action: SnackBarAction(
          label: l(context).postGoUnreadYes,
          onPressed: () => sls.fetch(
            clearItems: true,
            fc: FetchContext<_PostListItem>(
              path: widget.thread.links.postsUnread,
              state: sls,
            ),
          ),
        ),
        content: Text(l(context).postGoUnreadQuestion),
        duration: const Duration(seconds: 10),
      ));

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
  int pageCurrent;
  int pageTotal;
  Post post;
  PostReply postReply;

  _PostListItem.post(this.post) : assert(post != null);

  _PostListItem.postReply(this.postReply) : assert(postReply != null);

  _PostListItem.page(this.pageCurrent, this.pageTotal)
      : assert(pageCurrent != null);

  int get postId => post?.postId ?? postReply?.postId;

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

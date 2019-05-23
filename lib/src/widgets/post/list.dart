part of '../posts.dart';

const _kPageIndicatorHeight = 40.0;

class _PostListWidget extends StatelessWidget {
  final Map initialJson;
  final String path;
  final Thread thread;

  _PostListWidget(
    this.thread, {
    this.initialJson,
    Key key,
    this.path,
  })  : assert(thread != null),
        super(key: key);

  @override
  Widget build(BuildContext context) => SuperListView<_PostListItem>(
        enableScrollToIndex: true,
        fetchPathInitial: path,
        fetchOnSuccess: _fetchOnSuccess,
        initialItems: thread.firstPost != null
            ? [_PostListItem.post(thread.firstPost)]
            : null,
        initialJson: initialJson,
        itemBuilder: _buildItem,
        itemStreamRegister: (sls) => Provider.of<NewPostStream>(context).listen(
            (post) => sls.itemsInsert(
                sls.fetchedPageMin == 1 ? 1 : 0, _PostListItem.post(post))),
      );

  Widget _buildItem(
    BuildContext context,
    SuperListState state,
    _PostListItem item,
  ) {
    if (item.pageCurrent != null)
      return _buildPageIndicator(context, state, item);

    final post = item.post;
    if (post != null) {
      return post.postIsFirstPost
          ? _FirstPostWidget(thread, post)
          : _buildPostRoot(context, state, post);
    }

    return Container();
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
        _buildPageIndicatorText(context, 'Loading...'),
      ]);
    }

    final children = <Widget>[
      const Divider(height: _kPageIndicatorHeight),
      _buildPageIndicatorText(
        context,
        total == null ? "Page $page" : "Page $page of $total",
      ),
    ];

    if (page > state.fetchedPageMin) {
      if (page > 2) {
        children.add(_buildPageIndicatorText(
          context,
          "previous",
          alignment: Alignment.centerLeft,
          onTap: () => _scrollToPage(state, page - 1),
        ));
      } else {
        children.add(_buildPageIndicatorText(
          context,
          "top",
          alignment: Alignment.centerLeft,
          onTap: () => state.jumpTo(0),
        ));
      }
    } else if (state.canFetchPrev) {
      children.add(_buildPageIndicatorText(
        context,
        "previous",
        alignment: Alignment.centerLeft,
        onTap: () => state.fetchPrev(),
      ));
    }

    if (page < state.fetchedPageMax) {
      children.add(_buildPageIndicatorText(
        context,
        'next',
        alignment: Alignment.centerRight,
        onTap: () => _scrollToPage(state, page + 1),
      ));
    } else if (state.canFetchNext) {
      children.add(_buildPageIndicatorText(
        context,
        'next',
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

  Widget _buildPostRoot(
    BuildContext context,
    SuperListState<_PostListItem> state,
    Post post,
  ) =>
      MultiProvider(
        providers: [
          Provider<Post>.value(value: post),
          NewPostStream.buildProvider(),
        ],
        child: buildRow(
          context,
          buildPosterCircleAvatar(post.links.posterAvatar),
          box: <Widget>[
            buildPosterInfo(
              context,
              state,
              post.posterUsername,
              userId: post.posterUserId,
              userHasVerifiedBadge: post.posterHasVerifiedBadge,
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
            _PostRepliesWidget(post),
          ],
        ),
      );

  void _fetchOnSuccess(Map json, FetchContext<_PostListItem> fc) {
    if (!json.containsKey('posts')) return;

    final firstItemPostId =
        fc.state.items.isEmpty ? null : fc.state.items.first.post?.postId;
    final linksPage = fc.linksPage ?? 1;
    int pageOfPostId =
        json.containsKey('page_of_post_id') ? json['page_of_post_id'] : null;

    if (firstItemPostId != null || linksPage != 1) {
      fc.addItem(_PostListItem.page(linksPage, total: fc.linksPages));
    }

    final posts = decodePostsAndTheirReplies(json['posts'])
        .where((p) => p.postId != firstItemPostId);
    for (final post in posts) {
      if (firstItemPostId == null && linksPage == 1) {
        if (fc.items?.length == 1) {
          fc.addItem(_PostListItem.page(linksPage, total: fc.linksPages));
        }
      }

      if (pageOfPostId != null && fc.scrollToRelativeIndex == null) {
        if (post.postId == pageOfPostId) {
          fc.scrollToRelativeIndex = fc.items?.length ?? 0;
        } else {
          post.postReplies?.forEach((reply) => reply.postId == pageOfPostId
              ? fc.scrollToRelativeIndex = fc.items?.length ?? 0
              : null);
        }
      }

      fc.addItem(_PostListItem.post(post));
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
  final int pageCurrent;
  final int pageTotal;
  final Post post;

  _PostListItem.post(this.post)
      : pageCurrent = null,
        pageTotal = null,
        assert(post != null);

  _PostListItem.page(this.pageCurrent, {int total})
      : pageTotal = total,
        post = null,
        assert(pageCurrent != null);
}

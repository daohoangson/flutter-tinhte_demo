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
  State<StatefulWidget> createState() => _PostsWidgetState();
}

class _PostsWidgetState extends State<PostsWidget> {
  Thread thread;

  @override
  void initState() {
    super.initState();

    thread = widget.thread;
  }

  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: [
          Provider<Thread>.value(value: thread),
          NewPostStream.buildProvider(),
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
          itemStreamRegister: (sls) => Provider.of<NewPostStream>(sls.context)
              .listen((post) => sls.itemsInsert(
                    sls.fetchedPageMin == 1 ? 1 : 0,
                    _PostListItem.post(post),
                  )),
        ),
      );

  Widget _buildItem(
    BuildContext context,
    SuperListState state,
    _PostListItem item,
  ) {
    if (item.pageCurrent != null)
      return _buildPageIndicator(context, state, item);

    final post = item.post ?? item.postReplyPost;
    if (post != null) {
      return ActionablePost.buildMultiProvider(
        post,
        post.postIsFirstPost ? _FirstPostWidget() : _PostWidget(),
      );
    }

    final postReply = item.postReply;
    if (postReply != null) {
      final superListIndex = state.indexOf(item);
      assert(superListIndex > -1);
      return _PostReplyHiddenWidget(
        postReply,
        superListIndex,
      );
    }

    return null;
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

  void _fetchOnSuccess(Map json, FetchContext<_PostListItem> fc) {
    if (!json.containsKey('posts')) return;

    final firstItemPostId =
        fc.state.items.isEmpty ? null : fc.state.items.first.post?.postId;
    final linksPage = fc.linksPage ?? 1;
    int pageOfPostId =
        json.containsKey('page_of_post_id') ? json['page_of_post_id'] : null;

    if (firstItemPostId != null || linksPage != 1) {
      fc.addItem(_PostListItem.page(linksPage, fc.linksPages));
    }

    final items = decodePostsAndTheirReplies(json['posts']);
    for (final item in items) {
      if (firstItemPostId != null && item.postId == firstItemPostId) continue;

      if (firstItemPostId == null && linksPage == 1) {
        if (fc.items?.length == 1) {
          fc.addItem(_PostListItem.page(linksPage, fc.linksPages));
        }
      }

      if (pageOfPostId != null && item.postId == pageOfPostId)
        fc.scrollToRelativeIndex = fc.items?.length ?? 0;

      fc.addItem(item);
    }

    if (json.containsKey('thread')) {
      final thread = Thread.fromJson(json['thread']);
      setState(() => this.thread = thread);
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
  int pageCurrent;
  int pageTotal;

  Post post;

  PostReply postReply;
  Post postReplyPost;

  _PostListItem.post(this.post) : assert(post != null);

  _PostListItem.postReply(this.postReply) : assert(postReply != null);

  _PostListItem.page(this.pageCurrent, this.pageTotal)
      : assert(pageCurrent != null);

  int get postId => post?.postId ?? postReply?.postId;
}

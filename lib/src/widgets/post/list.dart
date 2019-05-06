part of '../posts.dart';

const _kPageIndicatorHeight = 40.0;

class _PostListWidget extends StatefulWidget {
  final Map<dynamic, dynamic> initialJson;
  final String path;
  final int scrollToPostId;
  final Thread thread;

  _PostListWidget(
    this.thread, {
    this.initialJson,
    Key key,
    this.path,
    this.scrollToPostId,
  })  : assert(thread != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() => _PostListWidgetState();
}

class _PostListWidgetState extends State<_PostListWidget> {
  final List<_PostListItem> items = List();

  final _controller = AutoScrollController();
  bool _isFetching = false;
  String _linkPrev;
  String _linkNext;
  int _pageRange0;
  int _pageRange1;
  VoidCallback _removeListener;

  int __scrollToPostId;
  var __scrollToNewItem = false;

  _PostListWidgetState();

  @override
  void initState() {
    super.initState();

    final firstPost = widget.thread.firstPost;
    if (firstPost != null) items.add(_PostListItem(post: firstPost));

    __scrollToPostId = widget.scrollToPostId;

    if (widget.initialJson != null) {
      fetchOnSuccess(widget.initialJson);
    } else {
      fetch(widget.path);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_removeListener != null) _removeListener();
    _removeListener = PostListInheritedWidget.of(context).addListener(
      (post) => setState(() => items.insert(0, _PostListItem(post: post))),
    );
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
  Widget build(BuildContext context) =>
      NotificationListener<ScrollNotification>(
        child: ListView.builder(
          controller: _controller,
          itemBuilder: (context, i) => AutoScrollTag(
                child: i < items.length
                    ? _buildItem(items[i])
                    : buildProgressIndicator(_isFetching),
                controller: _controller,
                index: i,
                key: ValueKey(i),
              ),
          itemCount: items.length + 1,
          padding: const EdgeInsets.all(0),
        ),
        onNotification: (scrollInfo) {
          if (!(scrollInfo is ScrollEndNotification)) return;
          if (_controller.isAutoScrolling) return;

          final m = scrollInfo.metrics;
          if (m.pixels < m.maxScrollExtent - m.viewportDimension) {
            return;
          }

          if (_linkNext?.isNotEmpty != true) return;
          fetch(_linkNext);
        },
      );

  void fetch(String path) {
    if (_isFetching) return;
    setState(() => _isFetching = true);

    apiGet(
      this,
      path,
      onSuccess: fetchOnSuccess,
      onComplete: () => setState(() => _isFetching = false),
    );
  }

  void fetchOnSuccess(Map<dynamic, dynamic> json) {
    final List<_PostListItem> newItems = List();
    Links newLinks;

    if (json.containsKey('posts')) {
      final firstItemPostId = items.isEmpty ? null : items.first.post?.postId;

      if (json.containsKey('links')) {
        newLinks = Links.fromJson(json['links']);
        if (firstItemPostId != null || newLinks.page != 1) {
          newItems.add(_PostListItem(page: newLinks.page));
        }
      }

      decodePostsAndTheirReplies(json['posts'])
          .where((p) => p.postId != firstItemPostId)
          .forEach(
        (post) {
          if (firstItemPostId == null && newLinks?.page == 1) {
            if (newItems.length == 1) {
              newItems.add(_PostListItem(page: newLinks.page));
            }
          }

          newItems.add(_PostListItem(post: post));
        },
      );
    }

    int scrollToIndex;
    if (__scrollToPostId != null) {
      for (int i = 0; i < newItems.length; i++) {
        final post = newItems[i].post;
        if (post == null) continue;

        if (post.postId == __scrollToPostId) {
          scrollToIndex = items.length + i;
          break;
        }

        for (final reply in post.postReplies) {
          if (reply.postId == __scrollToPostId) {
            scrollToIndex = items.length + i;
            break;
          }
        }
      }
    } else if (__scrollToNewItem) {
      scrollToIndex = items.length;
    }
    __scrollToPostId = null;
    __scrollToNewItem = false;

    setState(() {
      var prepend = false;
      if (newLinks != null) {
        if (_pageRange0 == null || _pageRange0 > newLinks.page) {
          if (_pageRange0 != null) prepend = true;
          _linkPrev = newLinks.prev;
          _pageRange0 = newLinks.page;
        }
        if (_pageRange1 == null || _pageRange1 < newLinks.page) {
          _linkNext = newLinks.next;
          _pageRange1 = newLinks.page;
        }
      }

      if (prepend) {
        items.insertAll(0, newItems);
      } else {
        items.addAll(newItems);
      }

      if (scrollToIndex != null) {
        _controller.scrollToIndex(
          scrollToIndex,
          preferPosition: AutoScrollPosition.begin,
        );
      }
    });
  }

  Widget _buildItem(_PostListItem item) {
    if (item.page != null) return _buildPageIndicator(item.page);

    final post = item.post;
    if (post != null) {
      return post.postIsFirstPost
          ? _FirstPostWidget(widget.thread, post)
          : _buildPostRoot(post);
    }

    return Container();
  }

  Widget _buildPageIndicator(int page) {
    if (_isFetching) {
      return Stack(children: <Widget>[
        const Divider(height: _kPageIndicatorHeight),
        _buildPageIndicatorText('Loading...'),
      ]);
    }

    final children = <Widget>[
      const Divider(height: _kPageIndicatorHeight),
      _buildPageIndicatorText("Page $page"),
    ];

    if (page > _pageRange0) {
      if (page > 2) {
        children.add(_buildPageIndicatorText(
          "previous",
          alignment: Alignment.centerLeft,
          onTap: () => _scrollToPage(page - 1),
        ));
      } else {
        children.add(_buildPageIndicatorText(
          "top",
          alignment: Alignment.centerLeft,
          onTap: () => _controller.scrollToIndex(0),
        ));
      }
    } else if (_linkPrev?.isNotEmpty == true) {
      children.add(_buildPageIndicatorText(
        "previous",
        alignment: Alignment.centerLeft,
        onTap: () => fetch(_linkPrev),
      ));
    }

    if (page < _pageRange1) {
      children.add(_buildPageIndicatorText(
        'next',
        alignment: Alignment.centerRight,
        onTap: () => _scrollToPage(page + 1),
      ));
    } else if (_linkNext?.isNotEmpty == true) {
      children.add(_buildPageIndicatorText(
        'next',
        alignment: Alignment.centerRight,
        onTap: () {
          __scrollToNewItem = true;
          fetch(_linkNext);
        },
      ));
    }

    return Stack(children: children);
  }

  Widget _buildPageIndicatorText(
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

  Widget _buildPostRoot(Post post) => _ParentPostInheritedWidget(
        parentPost: post,
        child: PostListInheritedWidget(
          child: buildRow(
            context,
            buildPosterCircleAvatar(post.links.posterAvatar),
            box: <Widget>[
              buildPosterInfo(
                context,
                post.posterUsername,
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
        ),
      );

  void _scrollToPage(int page) {
    for (int i = 0; i < items.length; i++) {
      if (items[i].page != page) continue;

      _controller.scrollToIndex(i, preferPosition: AutoScrollPosition.begin);
      return;
    }
  }
}

class _PostListItem {
  final int page;
  final Post post;

  _PostListItem({this.page, this.post})
      : assert((page == null) != (post == null));
}

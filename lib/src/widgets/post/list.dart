part of '../posts.dart';

const _kItemCountForFirstPost = 1;
const _kItemCountForPageNav = 1;

class _PostListWidget extends StatefulWidget {
  final String path;
  final Thread thread;

  _PostListWidget(
    this.thread, {
    Key key,
    this.path,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PostListWidgetState();
}

class _PostListWidgetState extends State<_PostListWidget> {
  final List<_PostListItem> items = List();

  Widget _firstPost;
  bool _isFetching = false;
  Links _links;
  VoidCallback _removeListener;
  bool _showFirstPost = true;

  bool get hasFirstPost => _showFirstPost && widget.thread?.firstPost != null;
  bool get hasLinks => _links != null;
  ScrollController get scrollController => PrimaryScrollController.of(context);

  _PostListWidgetState();

  @override
  void initState() {
    super.initState();
    fetch(widget.path);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_removeListener != null) _removeListener();
    _removeListener = PostListInheritedWidget.of(context).addListener(
        (post) => setState(() => items.insert(0, _PostListItem(post: post))));
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
  Widget build(BuildContext context) => ListView.builder(
        controller: scrollController,
        itemBuilder: (context, i) {
          if (hasFirstPost) {
            if (i == 0) return _buildFirstPost();
            i--;
          }

          if (i < items.length) return _buildItem(items[i]);
          i -= items.length;

          if (hasLinks) {
            if (i == 0) {
              if (_isFetching) return buildProgressIndicator(true);
              return PageNav(_links, callback: onPageNav);
            }
            i--;
          }

          return Container();
        },
        itemCount: (hasFirstPost ? _kItemCountForFirstPost : 0) +
            items.length +
            (hasLinks ? _kItemCountForPageNav : 0),
        padding: const EdgeInsets.all(0),
      );

  fetch(String path) {
    if (_isFetching) return;
    setState(() => _isFetching = true);

    apiGet(this, path,
        onSuccess: (jsonMap) {
          final List<_PostListItem> newItems = List();
          Links newLinks;

          if (jsonMap.containsKey('posts')) {
            if (jsonMap.containsKey('links')) {
              newLinks = Links.fromJson(jsonMap['links']);
              newItems.add(_PostListItem(page: newLinks.page));
            }

            decodePostsAndTheirReplies(jsonMap['posts'])
                .where((p) => !p.postIsFirstPost)
                .forEach((post) => newItems.add(_PostListItem(post: post)));
          }

          setState(() {
            items.addAll(newItems);
            _links = newLinks;
          });
        },
        onComplete: () => setState(() => _isFetching = false));
  }

  onPageNav(int page, String url) {
    if (_isFetching) return;

    if (page < _links.page) {
      // TODO: find a better way to do this, may need to wait for this
      // https://github.com/flutter/flutter/issues/12319
      setState(() {
        _showFirstPost = false;
        items.clear();
      });
      scrollController.animateTo(
        -100.0,
        duration: const Duration(milliseconds: 10),
        curve: Curves.ease,
      );
    }

    fetch(url);
  }

  Widget _buildFirstPost() {
    _firstPost ??= _FirstPostWidget(widget.thread);
    return _firstPost;
  }

  Widget _buildItem(_PostListItem item) {
    if (item.page != null) {
      return _buildPageIndicator(item.page);
    }

    if (item.post != null) {
      return _buildPostRoot(item.post);
    }

    return Container();
  }

  Widget _buildPageIndicator(int page) {
    if (page == 1) return Container();

    return Stack(
      children: <Widget>[
        Divider(
          height: 40.0,
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.center,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  "Page $page",
                  style: Theme.of(context).textTheme.caption,
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

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
}

class _PostListItem {
  final int page;
  final Post post;

  _PostListItem({this.page, this.post});
}

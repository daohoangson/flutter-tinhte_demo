part of '../posts.dart';

class _FirstPostWidget extends StatelessWidget {
  final Post post;
  final Thread thread;

  const _FirstPostWidget({Key key, @required this.post, @required this.thread})
      : assert(post != null),
        assert(thread != null),
        super(key: key);

  @override
  Widget build(BuildContext _) => AnimatedBuilder(
        animation: thread,
        builder: (_, __) => AnimatedBuilder(
          animation: post,
          builder: _builder,
        ),
      );

  Widget _builder(BuildContext context, Widget _) {
    final _threadImage = thread.threadPrimaryImage ?? thread.threadImage;
    final _isBackgroundPost = isBackgroundPost(post);
    final _isTinhteFact = isTinhteFact(thread);
    final _isCustomPost = _isBackgroundPost || _isTinhteFact;
    final _isThreadTitleRedundant =
        _isCustomPost || thread.isThreadTitleRedundant;

    Widget widget = Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ThreadNavigationWidget(thread),
          _isThreadTitleRedundant
              ? widget0
              : Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: kPaddingHorizontal,
                  ),
                  child: Text(
                    thread.threadTitle,
                    maxLines: null,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
          _isCustomPost
              ? Padding(
                  child: _isBackgroundPost
                      ? BackgroundPost(post)
                      : (_isTinhteFact
                          ? TinhteFact(
                              thread,
                              autoPlayVideo: true,
                              post: post,
                            )
                          : widget0),
                  padding: const EdgeInsets.symmetric(
                    horizontal: kPaddingHorizontal,
                  ),
                )
              : _PostBodyWidget(post: post),
          thread.threadHasPoll == true && thread.links.poll != null
              ? PollWidget(thread)
              : widget0,
          _buildTags(context, thread) ?? widget0,
          _isCustomPost || _threadImage?.displayMode == 'cover'
              ? widget0
              : _PostAttachmentsWidget.forPost(post) ?? widget0,
          _PostActionsWidget(post: post, showPostCreateDate: false),
        ],
      ),
    );

    if (!_isCustomPost && _threadImage?.displayMode == 'cover') {
      widget = Column(
        children: <Widget>[
          ThreadImageWidget.big(thread, _threadImage),
          widget,
        ],
      );
    }

    return widget;
  }

  Widget _buildTags(BuildContext context, Thread thread) {
    if (thread.threadTags?.isNotEmpty != true) return null;

    return Padding(
      child: Wrap(
        children: thread.threadTags
            .map((tagId, tagText) => MapEntry(tagId, _TagChip(tagId, tagText)))
            .values
            .toList(),
        spacing: 5,
      ),
      padding: const EdgeInsets.symmetric(horizontal: kPaddingHorizontal),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String tagId;
  final String tagText;

  _TagChip(this.tagId, this.tagText);

  @override
  Widget build(BuildContext context) => ActionChip(
        label: Text("#$tagText", style: TextStyle(fontSize: 11)),
        labelPadding: const EdgeInsets.symmetric(horizontal: 3),
        onPressed: () => parsePath('tags/$tagId', context: context),
      );
}

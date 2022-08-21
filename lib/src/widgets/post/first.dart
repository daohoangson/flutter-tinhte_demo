part of '../posts.dart';

class _FirstPostWidget extends StatelessWidget {
  final Post post;
  final Thread thread;

  const _FirstPostWidget({Key? key, required this.post, required this.thread})
      : super(key: key);

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: thread,
        builder: (_, __) => AnimatedBuilder(
          animation: post,
          builder: _builder,
        ),
      );

  Widget _builder(BuildContext context, Widget? _) {
    final threadImage = thread.threadPrimaryImage ?? thread.threadImage;
    final threadTitle = thread.threadTitle;
    final postIsBackground = isBackgroundPost(post);
    final threadIsTinhteFact = isTinhteFact(thread);
    final isCustomPost = postIsBackground || threadIsTinhteFact;
    final isThreadTitleRedundant =
        isCustomPost || thread.isThreadTitleRedundant;

    Widget widget = Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ThreadNavigationWidget(thread),
          isThreadTitleRedundant || threadTitle == null
              ? widget0
              : Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: kPaddingHorizontal,
                  ),
                  child: Text(
                    threadTitle,
                    maxLines: null,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
          isCustomPost
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: kPaddingHorizontal,
                  ),
                  child: postIsBackground
                      ? BackgroundPost(post)
                      : (threadIsTinhteFact
                          ? TinhteFact(
                              thread,
                              autoPlayVideo: true,
                              post: post,
                            )
                          : widget0),
                )
              : _PostBodyWidget(post: post),
          thread.threadHasPoll == true && thread.links?.poll != null
              ? PollWidget(thread)
              : widget0,
          _buildTags(context, thread) ?? widget0,
          isCustomPost || threadImage?.displayMode == 'cover'
              ? widget0
              : _PostAttachmentsWidget.forPost(post) ?? widget0,
          _PostActionsWidget(post: post, showPostCreateDate: false),
        ],
      ),
    );

    if (!isCustomPost && threadImage?.displayMode == 'cover') {
      widget = Column(
        children: <Widget>[
          ThreadImageWidget.big(thread, threadImage),
          widget,
        ],
      );
    }

    return widget;
  }

  Widget? _buildTags(BuildContext context, Thread thread) {
    final tags = thread.threadTags ?? const {};
    if (tags.isEmpty) return null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kPaddingHorizontal),
      child: Wrap(
        spacing: 5,
        children: tags
            .map((tagId, tagText) => MapEntry(tagId, _TagChip(tagId, tagText)))
            .values
            .toList(),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String tagId;
  final String tagText;

  const _TagChip(this.tagId, this.tagText);

  @override
  Widget build(BuildContext context) => ActionChip(
        label: Text("#$tagText", style: const TextStyle(fontSize: 11)),
        labelPadding: const EdgeInsets.symmetric(horizontal: 3),
        onPressed: () => parsePath('tags/$tagId', context: context),
      );
}

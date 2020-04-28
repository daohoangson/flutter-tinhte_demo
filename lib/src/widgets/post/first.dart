part of '../posts.dart';

class _FirstPostWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final post = Provider.of<Post>(context);
    final thread = Provider.of<Thread>(context);

    final _isBackgroundPost = isBackgroundPost(post);
    final _isTinhteFact = isTinhteFact(thread);
    final _isCustomPost = _isBackgroundPost || _isTinhteFact;
    final _isThreadTitleRedundant =
        _isCustomPost || isThreadTitleRedundant(thread, post);

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
                    style: Theme.of(context).textTheme.title,
                  ),
                ),
          _isCustomPost
              ? Padding(
                  child: _isBackgroundPost
                      ? BackgroundPost(post)
                      : (_isTinhteFact
                          ? TinhteFact(thread, post: post)
                          : widget0),
                  padding: const EdgeInsets.symmetric(
                    horizontal: kPaddingHorizontal,
                  ),
                )
              : _PostBodyWidget(),
          thread.threadHasPoll == true && thread.links.poll != null
              ? PollWidget(thread.links.poll)
              : widget0,
          _buildTags(context, thread) ?? widget0,
          _isCustomPost || thread.threadImage?.displayMode == 'cover'
              ? widget0
              : _PostAttachmentsWidget.forPost(post) ?? widget0,
          _PostActionsWidget(showPostCreateDate: false),
        ],
      ),
    );

    if (!_isCustomPost && thread.threadImage?.displayMode == 'cover') {
      widget = Column(
        children: <Widget>[
          ThreadImageWidget(
            image: thread.threadImage,
            threadId: thread.threadId,
          ),
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
            .map((tagId, tagText) => MapEntry(tagId, _TagChip(tagText)))
            .values
            .toList(),
        spacing: 5,
      ),
      padding: const EdgeInsets.symmetric(horizontal: kPaddingHorizontal),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String tagText;

  _TagChip(this.tagText);

  @override
  Widget build(BuildContext context) => ActionChip(
        label: Text("#$tagText", style: TextStyle(fontSize: 11)),
        labelPadding: const EdgeInsets.symmetric(horizontal: 3),
        onPressed: () => launchLink(
          context,
          "$configSiteRoot/tags?t=${Uri.encodeQueryComponent(tagText)}",
        ),
      );
}

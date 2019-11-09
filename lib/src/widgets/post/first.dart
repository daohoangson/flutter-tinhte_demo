part of '../posts.dart';

class _FirstPostWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final post = Provider.of<Post>(context);
    final thread = Provider.of<Thread>(context);
    var widget = _buildPost(context, post, thread);

    if (thread.threadImage?.displayMode == 'cover') {
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

  Widget _buildPost(BuildContext context, Post post, Thread thread) => Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ThreadNavigation(thread),
            isThreadTitleRedundant(thread, post)
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
            _PostBodyWidget(),
            _buildTags(context, thread) ?? widget0,
            thread.threadImage?.displayMode == 'cover'
                ? widget0
                : _PostAttachmentsWidget.forPost(post) ?? widget0,
            _PostActionsWidget(showPostCreateDate: false),
          ],
        ),
      );

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

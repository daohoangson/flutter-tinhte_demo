part of '../posts.dart';

class _FirstPostWidget extends StatelessWidget {
  final Thread thread;
  final Post post;

  _FirstPostWidget(
    this.thread,
    this.post, {
    Key key,
  })  : assert(thread != null),
        assert(post != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    var widget = buildPost(context, post);

    if (thread?.threadImage?.displayMode == 'cover') {
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

  Widget buildPost(BuildContext context, Post post) => Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            isThreadTitleRedundant(thread, post)
                ? Container()
                : Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: kPaddingHorizontal,
                      vertical: 10.0,
                    ),
                    child: Text(
                      thread.threadTitle,
                      maxLines: null,
                      style: Theme.of(context).textTheme.title,
                    ),
                  ),
            TinhteHtmlWidget(post.postBodyHtml, isFirstPost: true),
            thread.threadImage?.displayMode == 'cover'
                ? Container()
                : _PostAttachmentsWidget.forPost(post, thread: thread),
            _PostActionsWidget(post, showPostCreateDate: false),
          ],
        ),
      );
}

part of '../posts.dart';

class _FirstPostWidget extends StatelessWidget {
  final Thread thread;

  _FirstPostWidget(this.thread, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final post = thread?.firstPost;
    if (post == null) return Container(height: 0.0, width: 0.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          thread.isTitleRedundant()
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
          _PostAttachmentsWidget.forPost(post, thread: thread),
          _PostActionsWidget(post, showPostCreateDate: false),
        ],
      ),
    );
  }
}

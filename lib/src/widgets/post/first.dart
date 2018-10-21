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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: kPaddingHorizontal, vertical: 10.0),
            child: Text(
              thread.threadTitle,
              maxLines: null,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TinhteHtmlWidget(post.postBodyHtml, isFirstPost: true),
          _PostActionsWidget(post),
        ],
      ),
    );
  }
}

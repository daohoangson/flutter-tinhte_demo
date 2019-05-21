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
    var widget = _buildPost(context, post);

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

  Widget _buildForum(BuildContext context, Forum forum) => forum != null
      ? InkWell(
          child: Padding(
            child: Wrap(
              children: <Widget>[
                Text(
                  forum.title,
                  style: Theme.of(context).textTheme.caption,
                ),
              ],
              spacing: 5,
            ),
            padding: const EdgeInsets.all(kPaddingHorizontal),
          ),
          onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ForumViewScreen(forum)),
              ),
        )
      : SizedBox.shrink();

  Widget _buildPost(BuildContext context, Post post) => Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildForum(context, thread.forum),
            isThreadTitleRedundant(thread, post)
                ? Container()
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
            TinhteHtmlWidget(post.postBodyHtml, isFirstPost: true),
            _buildTags(context, thread) ?? Container(),
            thread.threadImage?.displayMode == 'cover'
                ? Container()
                : _PostAttachmentsWidget.forPost(post, thread: thread),
            _PostActionsWidget(post, showPostCreateDate: false),
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

class _TagChip extends StatefulWidget {
  final String tagText;

  _TagChip(this.tagText);

  @override
  State<StatefulWidget> createState() => _TagChipState();
}

class _TagChipState extends State<_TagChip> {
  @override
  Widget build(BuildContext context) => ActionChip(
        label: Text("#${widget.tagText}", style: TextStyle(fontSize: 11)),
        labelPadding: const EdgeInsets.symmetric(horizontal: 3),
        onPressed: () => launchLink(
              this,
              "$configSiteRoot/tags?t=${Uri.encodeQueryComponent(widget.tagText)}",
            ),
      );
}

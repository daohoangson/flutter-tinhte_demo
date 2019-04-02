part of '../threads.dart';

Widget buildThreadRow(BuildContext context, Thread thread) {
  final theme = Theme.of(context);
  final threadTitleIsRedundant = thread.isTitleRedundant();

  final postBodyAndMetadata = Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Padding(
        padding: const EdgeInsets.all(5.0),
        child: Text(
          thread.firstPost.postBodyPlainText,
          maxLines: threadTitleIsRedundant ? 6 : 3,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 5.0),
        child: LayoutBuilder(
          builder: (context, bc) {
            final text = RichText(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              text: buildThreadTextSpan(context, thread),
            );
            if (bc.maxWidth < 600.0) return text;

            return Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 5.0),
                  child: CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(
                        thread.links.firstPosterAvatar),
                    maxRadius: 12.0,
                  ),
                ),
                Expanded(child: text),
              ],
            );
          },
        ),
      ),
    ],
  );

  final bodyAndPossiblyImage = thread.threadImage != null
      ? Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              child: ThreadImageWidget(
                image: thread?.threadImage,
                threadId: thread?.threadId,
              ),
              height: 90.0,
            ),
            Expanded(child: postBodyAndMetadata),
          ],
        )
      : postBodyAndMetadata;

  final cardContents = threadTitleIsRedundant
      ? bodyAndPossiblyImage
      : Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text(
                thread.threadTitle,
                style: theme.textTheme.title,
              ),
            ),
            bodyAndPossiblyImage,
          ],
        );

  return GestureDetector(
    child: Card(child: cardContents),
    onTap: () => pushThreadViewScreen(context, thread),
  );
}

TextSpan buildThreadTextSpan(BuildContext context, Thread thread) {
  if (thread == null) return TextSpan(text: '');
  List<TextSpan> spans = List();

  final theme = Theme.of(context);

  if (thread.threadIsSticky == true) {
    spans.add(TextSpan(text: '📌 '));
  }

  spans.add(TextSpan(
    style: TextStyle(color: theme.accentColor, fontWeight: FontWeight.bold),
    text: thread.creatorUsername,
  ));

  final threadCreateDate =
      DateTime.fromMillisecondsSinceEpoch(thread.threadCreateDate * 1000);
  if (threadCreateDate.isAfter(DateTime.now().subtract(Duration(days: 7)))) {
    spans.add(TextSpan(
      style: TextStyle(color: theme.disabledColor),
      text: "  ${timeago.format(threadCreateDate)}",
    ));
  }

  if (thread.threadViewCount > 1500) {
    spans.add(TextSpan(
      style: TextStyle(color: theme.disabledColor),
      text: " ${formatNumber(thread.threadViewCount)} views",
    ));
  }

  if (thread.threadPostCount > 20) {
    spans.add(TextSpan(
      style: TextStyle(color: theme.disabledColor),
      text: " ${formatNumber(thread.threadPostCount - 1)} replies",
    ));
  }

  return TextSpan(
    children: spans,
    style: theme.textTheme.caption,
  );
}

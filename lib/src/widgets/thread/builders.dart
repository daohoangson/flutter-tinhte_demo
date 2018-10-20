part of '../threads.dart';

Widget buildThreadRow(BuildContext context, Thread thread) {
  final postBodyAndMetadata = Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Padding(
        padding: const EdgeInsets.all(5.0),
        child: Text(
          thread.firstPost.postBodyPlainText,
          maxLines: 3,
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

  return GestureDetector(
    child: Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Text(
              thread.threadTitle,
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
          ),
          bodyAndPossiblyImage,
        ],
      ),
    ),
    onTap: () => pushThreadViewScreen(context, thread),
  );
}

TextSpan buildThreadTextSpan(BuildContext context, Thread thread) {
  if (thread == null) return TextSpan(text: '');
  List<TextSpan> spans = List();

  spans.add(TextSpan(
    style: TextStyle(
      color: Theme.of(context).accentColor,
      fontWeight: FontWeight.bold,
    ),
    text: thread.creatorUsername,
  ));

  final threadCreateDate = timeago.format(
      DateTime.fromMillisecondsSinceEpoch(thread.threadCreateDate * 1000));
  spans.add(TextSpan(
    style: TextStyle(
      color: Theme.of(context).disabledColor,
    ),
    text: "  $threadCreateDate",
  ));

  if (thread.threadViewCount > 1500) {
    spans.add(TextSpan(
      style: TextStyle(
        color: Theme.of(context).disabledColor,
      ),
      text: " - ${formatNumber(thread.threadViewCount)} views",
    ));
  }

  if (thread.threadIsSticky == true) {
    spans.add(TextSpan(text: '  📌'));
  }

  if (thread.threadIsFollowed == true) {
    spans.add(TextSpan(text: '  👁'));
  }

  return TextSpan(
    children: spans,
    style: TextStyle(
      fontSize: 12.0,
    ),
  );
}

part of '../threads.dart';

Widget buildThreadRow(BuildContext context, Thread thread) {
  final theme = Theme.of(context);
  final threadTitleIsRedundant = isThreadTitleRedundant(thread);

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
            final creatorInfo = buildCreatorInfo(context, thread);
            if (bc.maxWidth < 600.0) return creatorInfo;

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
                Expanded(child: creatorInfo),
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

Widget buildCreatorInfo(BuildContext context, Thread thread) {
  if (thread == null) return null;
  final children = <Widget>[];

  final theme = Theme.of(context);
  final style = theme.textTheme.caption;

  if (thread.threadIsSticky == true) {
    children.add(Icon(
      FontAwesomeIcons.thumbtack,
      size: style.fontSize,
    ));
  }

  children.add(
    RichText(
      text: TextSpan(
        text: thread.creatorUsername,
        style: style.copyWith(
          color: theme.accentColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );

  if (thread.creatorHasVerifiedBadge == true) {
    children.add(Icon(
      FontAwesomeIcons.solidCheckCircle,
      color: kColorUserVerifiedBadge,
      size: style.fontSize,
    ));
  }

  final threadCreateDate =
      DateTime.fromMillisecondsSinceEpoch(thread.threadCreateDate * 1000);
  if (threadCreateDate.isAfter(DateTime.now().subtract(Duration(days: 7)))) {
    children.add(
      RichText(
        text: TextSpan(
          text: timeago.format(threadCreateDate),
          style: style.copyWith(color: theme.disabledColor),
        ),
      ),
    );
  }

  if (thread.threadViewCount > 1500) {
    children.add(
      RichText(
        text: TextSpan(
          text: "${formatNumber(thread.threadViewCount)} views",
          style: style.copyWith(color: theme.disabledColor),
        ),
      ),
    );
  }

  if (thread.threadPostCount > 20) {
    children.add(
      RichText(
        text: TextSpan(
          text: "${formatNumber(thread.threadPostCount - 1)} replies",
          style: style.copyWith(color: theme.disabledColor),
        ),
      ),
    );
  }

  return Wrap(
    children: children,
    spacing: 5,
  );
}

part of '../threads.dart';

Widget buildThreadRow(BuildContext context, Thread thread) {
  final theme = Theme.of(context);
  final style = theme.textTheme.caption;

  final left = SizedBox(
    child: ThreadImageWidget(
      image: thread?.threadThumbnail,
      threadId: thread?.threadId,
    ),
    height: 80,
  );

  final right = Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Padding(
        child: buildCreatorInfoWithAvatar(thread, style),
        padding: const EdgeInsets.only(bottom: 5),
      ),
      Text(thread.threadTitle),
    ],
  );

  return GestureDetector(
    child: Padding(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              child: left,
              padding: const EdgeInsets.only(right: 10),
            ),
            Expanded(child: right),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5)),
    onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ThreadViewScreen(thread)),
        ),
  );
}

Widget buildCreatorInfo(BuildContext context, Thread thread, TextStyle style) {
  if (thread == null) return null;
  final theme = Theme.of(context);

  final children = <Widget>[
    RichText(
      text: TextSpan(
        text: thread.creatorUsername,
        style: style.copyWith(
          color: theme.accentColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  ];

  if (thread.creatorHasVerifiedBadge == true) {
    children.add(Icon(
      FontAwesomeIcons.solidCheckCircle,
      color: kColorUserVerifiedBadge,
      size: style.fontSize,
    ));
  }

  children.add(
    RichText(
      text: TextSpan(
        text: formatTimestamp(thread.threadCreateDate),
        style: style.copyWith(color: theme.disabledColor),
      ),
    ),
  );

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

Widget buildCreatorInfoWithAvatar(Thread thread, TextStyle style) =>
    LayoutBuilder(
      builder: (context, bc) {
        final creatorInfo = buildCreatorInfo(context, thread, style);
        if (bc.maxWidth < 300) return creatorInfo;

        return Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 5.0),
              child: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(
                  thread.links.firstPosterAvatar,
                ),
                maxRadius: style.fontSize,
              ),
            ),
            Expanded(child: creatorInfo),
          ],
        );
      },
    );

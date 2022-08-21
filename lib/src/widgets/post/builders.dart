part of '../posts.dart';

const kPaddingHorizontal = 10.0;
const kEdgeInsetsHorizontal = EdgeInsets.symmetric(
  horizontal: kPaddingHorizontal,
);
const kAvatarRootRadius = kToolbarHeight / 4;
const kAvatarReplyToRadius = kToolbarHeight / 5;

Widget buildPostButton(
  BuildContext context,
  String text, {
  Color? color,
  int count = 0,
  GestureTapCallback? onTap,
}) {
  final theme = Theme.of(context);
  final fontSize = theme.textTheme.button?.fontSize;

  Widget button = TextButton(
    onPressed: onTap,
    child: Text(
      (count > 0 ? "$count • " : '') + text,
      style: fontSize != null ? TextStyle(fontSize: fontSize - 2) : null,
    ),
  );

  button = ButtonTheme.fromButtonThemeData(
    data: ButtonTheme.of(context).copyWith(height: 0, minWidth: 0),
    child: button,
  );

  return button;
}

Widget buildPostRow(
  BuildContext context,
  Widget avatar, {
  required List<Widget> box,
  required List<Widget> footer,
}) {
  final children = <Widget>[
    Padding(
      padding: kEdgeInsetsHorizontal,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: DecoratedBox(
          decoration: BoxDecoration(color: Theme.of(context).highlightColor),
          child: Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: box,
              )),
        ),
      ),
    ),
    ...footer,
  ];

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        avatar,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ],
    ),
  );
}

Widget buildPosterCircleAvatar(String? url, {bool isPostReply = false}) =>
    Padding(
      padding: EdgeInsets.only(
        left: kPaddingHorizontal,
        top: isPostReply ? (kAvatarRootRadius - kAvatarReplyToRadius) : 0,
      ),
      child: CircleAvatar(
        backgroundImage: url != null ? CachedNetworkImageProvider(url) : null,
        radius: isPostReply ? kAvatarReplyToRadius : kAvatarRootRadius,
      ),
    );

Widget buildPosterInfo(
  BuildContext context,
  String? username, {
  int? userId,
  bool? userHasVerifiedBadge,
  String? userRank,
}) {
  final theme = Theme.of(context);
  final style = theme.textTheme.caption;
  final children = <Widget>[
    RichText(
      text: TextSpan(
        text: username,
        style: style?.copyWith(
          color: theme.colorScheme.secondary,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  ];

  if (userHasVerifiedBadge == true) {
    children.add(Icon(
      FontAwesomeIcons.solidCircleCheck,
      color: theme.colorScheme.secondary,
      size: style?.fontSize,
    ));
  }

  if (userRank?.isNotEmpty == true) {
    children.add(RichText(
      text: TextSpan(
        text: userRank,
        style: style?.copyWith(color: theme.hintColor),
      ),
    ));
  }

  Widget built = Wrap(
    spacing: 5,
    children: children,
  );

  if (userId != null) {
    built = GestureDetector(
      child: built,
      onTap: () => launchMemberView(context, userId),
    );
  }

  return Padding(
    padding: kEdgeInsetsHorizontal,
    child: built,
  );
}

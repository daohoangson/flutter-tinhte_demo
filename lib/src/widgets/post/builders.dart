part of '../posts.dart';

const kPaddingHorizontal = 10.0;
const kEdgeInsetsHorizontal = EdgeInsets.symmetric(
  horizontal: kPaddingHorizontal,
);

Widget buildButton(
  BuildContext context,
  String text, {
  Color color,
  int count = 0,
  GestureTapCallback onTap,
}) {
  final theme = Theme.of(context);

  Widget button = Padding(
    padding: const EdgeInsets.fromLTRB(kPaddingHorizontal, 5.0, 0.0, 5.0),
    child: Text(
      (count > 0 ? "$count " : '') + text,
      style: TextStyle(
        color: onTap != null
            ? color ?? theme.primaryColor
            : color ?? theme.disabledColor,
        fontSize: theme.textTheme.button.fontSize - 2,
      ),
    ),
  );

  if (onTap != null) {
    button = InkWell(
      onTap: onTap,
      child: button,
    );
  }

  return button;
}

Widget buildPosterCircleAvatar(String url, {bool isPostReply = false}) =>
    Padding(
      padding: const EdgeInsets.only(left: kPaddingHorizontal),
      child: CircleAvatar(
        backgroundImage: url != null ? CachedNetworkImageProvider(url) : null,
        radius: isPostReply ? kToolbarHeight / 5 : kToolbarHeight / 4,
      ),
    );

Widget buildPosterInfo(
  BuildContext context,
  String username, {
  String userRank,
}) =>
    Padding(
      padding: kEdgeInsetsHorizontal,
      child: RichText(
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          children: <TextSpan>[
            TextSpan(
              style: TextStyle(
                color: Theme.of(context).accentColor,
                fontWeight: FontWeight.bold,
              ),
              text: username,
            ),
            TextSpan(
              style: TextStyle(
                color: kColorUserRank,
                fontWeight: FontWeight.bold,
              ),
              text: "  ${userRank ?? ''}",
            ),
          ],
          style: Theme.of(context).textTheme.caption,
        ),
      ),
    );

Widget buildRow(
  BuildContext context,
  Widget avatar, {
  List<Widget> box,
  List<Widget> footer,
}) {
  final List<Widget> children = List();

  if (box != null) {
    children.add(Padding(
      padding: kEdgeInsetsHorizontal,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2.0),
          color: Theme.of(context).highlightColor,
        ),
        child: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: box.where((widget) => widget != null).toList(),
            )),
      ),
    ));
  }

  if (footer != null) {
    children.addAll(footer.where((widget) => widget != null));
  }

  return Padding(
    padding: const EdgeInsets.only(bottom: 10.0),
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

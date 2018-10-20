part of '../posts.dart';

const kPaddingHorizontal = 10.0;

Widget buildButton(
  BuildContext context,
  String text,
  GestureTapCallback onTap, {
  Color color,
  int count = 0,
}) =>
    InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: kPaddingHorizontal, vertical: 5.0),
        child: Text(
          (count > 0 ? "$count " : '') + text,
          style: TextStyle(
            color: color ?? Theme.of(context).accentColor,
            fontSize: 12.0,
          ),
        ),
      ),
    );

Widget buildPosterCircleAvatar(String url, {bool isPostReply = false}) =>
    Padding(
      padding: const EdgeInsets.only(left: kPaddingHorizontal),
      child: CircleAvatar(
        backgroundImage: CachedNetworkImageProvider(url ?? ''),
        radius: isPostReply ? 15.0 : 18.0,
      ),
    );

Widget buildPosterInfo(
  BuildContext context,
  String username, {
  int date,
}) =>
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: kPaddingHorizontal),
      child: RichText(
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
                color: Theme.of(context).disabledColor,
              ),
              text: "  ${date != null ? formatTimestamp(date) : 'now'}",
            ),
          ],
          style: DefaultTextStyle.of(context).style.copyWith(
                fontSize: 12.0,
              ),
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
      padding: const EdgeInsets.symmetric(horizontal: kPaddingHorizontal),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2.0),
          color: Theme.of(context).highlightColor,
        ),
        child: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: box,
            )),
      ),
    ));
  }

  if (footer != null) {
    children.addAll(footer);
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

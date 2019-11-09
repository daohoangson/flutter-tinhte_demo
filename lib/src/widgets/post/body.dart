part of '../posts.dart';

TextStyle getPostBodyTextStyle(BuildContext context, bool isFirstPost) {
  final themeStyle = Theme.of(context).textTheme.body1;
  return themeStyle.copyWith(
    fontSize: themeStyle.fontSize + (isFirstPost ? 1 : 0),
  );
}

class _PostBodyWidget extends StatelessWidget {
  final bool needBottomMargin;

  _PostBodyWidget({this.needBottomMargin});

  @override
  Widget build(BuildContext context) => Consumer<ActionablePost>(
        builder: (context, ap, _) {
          final post = ap.post;

          if (post.postIsDeleted)
            return Padding(
              child: Text(
                'Deleted post.',
                style: Theme.of(context).textTheme.caption.copyWith(
                      decoration: TextDecoration.lineThrough,
                    ),
              ),
              padding: const EdgeInsets.all(kPostBodyPadding),
            );

          return TinhteHtmlWidget(
            ap.post.postBodyHtml,
            needBottomMargin: needBottomMargin,
            textStyle: getPostBodyTextStyle(context, post.postIsFirstPost),
          );
        },
      );
}

part of '../posts.dart';

TextStyle getPostBodyTextStyle(BuildContext context, bool isFirstPost) {
  final themeStyle = Theme.of(context).textTheme.bodyText2;
  return themeStyle.copyWith(
    fontSize: (themeStyle.fontSize + (isFirstPost ? 1 : 0)) *
        context.watch<FontScale>().value,
  );
}

class _PostBodyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Consumer<ActionablePost>(
        builder: (context, ap, _) {
          final post = ap.post;

          if (post.postIsDeleted)
            return Padding(
              child: Text(
                l(context).postDeleted,
                style: Theme.of(context).textTheme.caption.copyWith(
                      decoration: TextDecoration.lineThrough,
                    ),
              ),
              padding: const EdgeInsets.all(kPostBodyPadding),
            );

          return DefaultTextStyle(
            child: TinhteHtmlWidget(post.postBodyHtml),
            style: getPostBodyTextStyle(context, post.postIsFirstPost),
          );
        },
      );
}

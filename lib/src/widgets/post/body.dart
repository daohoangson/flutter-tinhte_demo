part of '../posts.dart';

TextStyle getPostBodyTextStyle(BuildContext context, bool isFirstPost) {
  final themeStyle = Theme.of(context).textTheme.bodyText2;
  return themeStyle.copyWith(
    fontSize: (themeStyle.fontSize + (isFirstPost ? 1 : 0)) *
        context.watch<FontScale>().value,
  );
}

class _PostBodyWidget extends StatelessWidget {
  final Post post;

  const _PostBodyWidget({Key key, @required this.post})
      : assert(post != null),
        super(key: key);

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: post,
        builder: (context, _) {
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

          final html = post.postBodyHtml;
          if (html.isEmpty) {
            return const SizedBox(height: 10);
          }

          return DefaultTextStyle(
            child: TinhteHtmlWidget(html),
            style: getPostBodyTextStyle(context, post.postIsFirstPost),
          );
        },
      );
}

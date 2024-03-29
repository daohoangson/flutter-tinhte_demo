part of '../posts.dart';

class _PostBodyWidget extends StatelessWidget {
  final Post post;

  const _PostBodyWidget({required this.post});

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: post,
        builder: (context, _) {
          if (post.postIsDeleted) {
            return Padding(
              padding: const EdgeInsets.all(kPostBodyPadding),
              child: Text(
                l(context).postDeleted,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      decoration: TextDecoration.lineThrough,
                    ),
              ),
            );
          }

          Widget built = const SizedBox(height: 10);

          final html = (post.postBodyHtml ?? '').trim();
          if (html.isNotEmpty) {
            built = TinhteHtmlWidget(html);
          }

          final style =
              _getPostBodyTextStyle(context, post.postIsFirstPost == true);
          if (style != null) {
            built = DefaultTextStyle(style: style, child: built);
          }

          return built;
        },
      );
}

TextStyle? _getPostBodyTextStyle(BuildContext context, bool isFirstPost) {
  final themeStyle = Theme.of(context).textTheme.bodyMedium;
  if (themeStyle == null) return null;

  final size = themeStyle.fontSize;
  if (size == null) return themeStyle;

  final scale = context.watch<FontScale>().value;
  return themeStyle.copyWith(fontSize: (size + (isFirstPost ? 1 : 0)) * scale);
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:the_api/post.dart';
import 'package:the_app/src/widgets/html.dart';
import 'package:the_app/src/widgets/posts.dart';

bool isBackgroundPost(Post post) =>
    post.postBodyHtml
        ?.contains('<span class="metaBbCode meta-thread_background_url">') ??
    false;

class BackgroundPost extends StatelessWidget {
  final Post post;

  const BackgroundPost(
    this.post, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme =
        ThemeData.localize(ThemeData.dark(), Theme.of(context).textTheme);

    return Theme(
      data: theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(kPaddingHorizontal),
              color: theme.primaryColorDark,
            ),
            child: _buildWithBackground(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildWithBackground(ThemeData theme) {
    final regExp =
        RegExp(r'<span class="metaBbCode meta-thread_background_url">.+'
            r'<a href="([^"]+)"[^>]+>([^<]+)</a>'
            r'</span></span>');
    final postBodyHtml0 = post.postBodyHtml ?? '';
    final m = regExp.firstMatch(postBodyHtml0);
    final href = m?.group(1);
    final text = m?.group(2);
    final threadBackgroundUrl = href == text ? href : null;
    final postBodyHtml = threadBackgroundUrl != null
        ? postBodyHtml0.replaceAll(m!.group(0)!, '')
        : postBodyHtml0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(kPaddingHorizontal),
      child: Container(
        decoration: threadBackgroundUrl != null
            ? BoxDecoration(
                image: DecorationImage(
                  image: CachedNetworkImageProvider(threadBackgroundUrl),
                  fit: BoxFit.cover,
                ),
              )
            : null,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 300),
          child: Center(
            child: TinhteHtmlWidget(
              "<center>$postBodyHtml</center>",
              textStyle: theme.textTheme.titleLarge,
            ),
          ),
        ),
      ),
    );
  }
}

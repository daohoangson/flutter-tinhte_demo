import 'package:flutter/material.dart';
import 'package:the_api/post.dart';
import 'package:the_app/src/abstracts/cached_network_image.dart' as cached;
import 'package:the_app/src/constants.dart';
import 'package:the_app/src/widgets/html.dart';

// try to match the paddings for a smooth curve
const _kBorderRadius = kPadding;

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
              borderRadius: BorderRadius.circular(_kBorderRadius),
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
        RegExp(r'<span class="metaBbCode meta-threadbackgroundurl">.+'
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
      borderRadius: BorderRadius.circular(_kBorderRadius),
      child: Container(
        decoration: threadBackgroundUrl != null
            ? BoxDecoration(
                image: DecorationImage(
                  image: cached.image(threadBackgroundUrl),
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

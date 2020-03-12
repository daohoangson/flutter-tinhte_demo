import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tinhte_api/post.dart';
import 'package:tinhte_demo/src/widgets/posts.dart';

import '../html.dart';

bool isBackgroundPost(Post post) =>
    post.postBodyHtml
        ?.contains('<span class="metaBbCode meta-thread_background_url">') ??
    false;

class BackgroundPost extends StatelessWidget {
  final Post post;

  const BackgroundPost(
    this.post, {
    Key key,
  })  : assert(post != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme =
        ThemeData.localize(ThemeData.dark(), Theme.of(context).textTheme);

    return Theme(
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
      data: theme,
    );
  }

  Widget _buildWithBackground(ThemeData theme) {
    final regExp =
        RegExp(r'<span class="metaBbCode meta-thread_background_url">.+'
            r'<a href="([^"]+)"[^>]+>([^<]+)</a>'
            r'</span></span>');
    final postBodyHtml = post.postBodyHtml;
    final m = regExp.firstMatch(postBodyHtml);
    final href = m?.group(1);
    final text = m?.group(2);
    final threadBackgroundUrl = href == text ? href : null;
    final _postBodyHtml = threadBackgroundUrl != null
        ? postBodyHtml.replaceAll(m.group(0), '')
        : postBodyHtml;

    return Stack(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 4 / 3,
          child: threadBackgroundUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(kPaddingHorizontal),
                  child: CachedNetworkImage(
                    imageUrl: threadBackgroundUrl,
                    fit: BoxFit.cover,
                  ),
                )
              : const SizedBox.shrink(),
        ),
        Positioned.fill(
          child: Center(
            child: TinhteHtmlWidget(
              "<center>$_postBodyHtml</center>",
              textStyle: theme.textTheme.title,
            ),
          ),
        )
      ],
    );
  }
}
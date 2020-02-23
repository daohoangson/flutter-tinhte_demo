import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tinhte_api/post.dart';
import 'package:tinhte_api/thread.dart';
import 'package:tinhte_demo/src/widgets/posts.dart';

import 'html.dart';
import 'image.dart';

bool isTinhteFact(Thread thread) =>
    thread.threadTags?.values
        ?.fold(false, (prev, tagText) => prev || tagText == 'tinhtefact') ??
    false;

class TinhteFact extends StatelessWidget {
  final Thread thread;
  final Post post;

  String get postBodyHtml => (post ?? thread.firstPost)?.postBodyHtml ?? '';

  const TinhteFact(
    this.thread, {
    Key key,
    this.post,
  })  : assert(thread != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData.localize(ThemeData.dark(), Theme.of(context).textTheme);

    return Theme(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(kPaddingHorizontal),
              color: theme.primaryColorDark,
            ),
            child: thread.threadImage != null
                ? _buildUserImage(theme)
                : _buildWithBackground(theme),
          ),
        ],
      ),
      data: theme,
    );
  }

  Widget _buildUserImage(ThemeData theme) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(kPaddingHorizontal),
            child: Text(
              thread.threadTitle,
              maxLines: null,
              style: theme.textTheme.title.copyWith(
                color: theme.accentColor,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          ThreadImageWidget(
            image: thread.threadImage,
            threadId: thread.threadId,
          ),
          TinhteHtmlWidget(
            "<center>$postBodyHtml</center>",
            textStyle: theme.textTheme.body1,
          ),
        ],
      );

  Widget _buildWithBackground(ThemeData theme) {
    final regExp =
        RegExp(r'<span class="metaBbCode meta-thread_background_url">.+'
            r'<a href="([^"]+)"[^>]+>([^<]+)</a>'
            r'</span></span>');
    final m = regExp.firstMatch(postBodyHtml);
    final href = m?.group(1);
    final text = m?.group(2);
    final threadBackgroundUrl = href == text ? href : null;
    final _postBodyHtml = threadBackgroundUrl != null
        ? postBodyHtml.replaceAll(m.group(0), '')
        : postBodyHtml;
    print(postBodyHtml);

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

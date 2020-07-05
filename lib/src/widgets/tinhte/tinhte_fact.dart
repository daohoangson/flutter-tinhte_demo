import 'package:flutter/material.dart';
import 'package:the_api/post.dart';
import 'package:the_api/thread.dart';
import 'package:the_app/src/widgets/html.dart';
import 'package:the_app/src/widgets/image.dart';
import 'package:the_app/src/widgets/posts.dart';

bool isTinhteFact(Thread thread) =>
    thread.threadImage != null &&
    (thread.threadTags?.values
            ?.fold(false, (prev, tagText) => prev || tagText == 'tinhtefact') ??
        false);

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
            child: _buildUserImage(theme),
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
              style: theme.textTheme.headline6.copyWith(
                color: theme.accentColor,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          ThreadImageWidget(
            image: thread.threadImage,
            threadId: thread.threadId,
            useImageRatio: true,
          ),
          TinhteHtmlWidget(
            "<center>$postBodyHtml</center>",
            textStyle: theme.textTheme.bodyText2,
          ),
        ],
      );
}

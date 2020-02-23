import 'package:flutter/material.dart';
import 'package:tinhte_api/post.dart';
import 'package:tinhte_api/thread.dart';
import 'package:tinhte_demo/src/widgets/posts.dart';

import 'html.dart';
import 'image.dart';

bool isTinhteFact(Thread thread) =>
    thread.threadImage != null &&
    // TODO: add support for thread_background_url
    (thread.threadTags?.values
            ?.fold(false, (prev, tagText) => prev || tagText == 'tinhtefact') ??
        false);

class TinhteFact extends StatelessWidget {
  final Thread thread;
  final Post post;

  const TinhteFact(
    this.thread, {
    Key key,
    this.post,
  })  : assert(thread != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData.dark();

    return Theme(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(kPaddingHorizontal),
              color: theme.primaryColorDark,
            ),
            child: Column(
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
                  "<center>${(post ?? thread.firstPost).postBodyHtml}</center>",
                  textStyle: theme.textTheme.body1,
                ),
              ],
            ),
          ),
        ],
      ),
      data: theme,
    );
  }
}

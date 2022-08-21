import 'package:flutter/material.dart';
import 'package:the_api/attachment.dart';
import 'package:the_api/post.dart';
import 'package:the_api/thread.dart';
import 'package:the_app/src/widgets/html.dart';
import 'package:the_app/src/widgets/image.dart';
import 'package:the_app/src/widgets/posts.dart';
import 'package:the_app/src/widgets/video_player.dart';

bool isTinhteFact(Thread thread) =>
    thread.threadImage != null &&
    (thread.threadTags?.values
            ?.fold(false, (prev, tagText) => prev || tagText == 'tinhtefact') ??
        false);

class TinhteFact extends StatelessWidget {
  final bool autoPlayVideo;
  final Post post;
  final Thread thread;

  Post get firstPost => post ?? thread.firstPost;

  const TinhteFact(
    this.thread, {
    this.autoPlayVideo = false,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(kPaddingHorizontal),
                  child: Text(
                    thread.threadTitle ?? '',
                    maxLines: null,
                    style: theme.textTheme.headline6?.copyWith(
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                _buildContents(),
                TinhteHtmlWidget(
                  "<center>${firstPost?.postBodyHtml ?? ''}</center>",
                  textStyle: theme.textTheme.bodyText2,
                ),
              ],
            ),
          ),
        ],
      ),
      data: theme,
    );
  }

  Widget _buildContents() {
    Attachment threadImageAttachment;
    final threadImageLink = thread.threadImage?.link;
    for (final attachment in firstPost?.attachments ?? const []) {
      if (attachment.links.permalink == threadImageLink ||
          attachment.links.thumbnail == threadImageLink) {
        threadImageAttachment = attachment;
      }
    }

    if (threadImageAttachment != null && threadImageAttachment.isVideo) {
      final video = threadImageAttachment;
      final aspectRatio = video.aspectRatio;
      final videoUrl = video.links?.xVideoUrl;
      if (aspectRatio != null && videoUrl != null) {
        return VideoPlayer(
          aspectRatio: aspectRatio,
          autoPlay: autoPlayVideo,
          url: videoUrl,
        );
      }
    }

    return ThreadImageWidget.big(thread, thread.threadImage);
  }
}

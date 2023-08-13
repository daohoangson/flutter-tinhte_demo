import 'package:flutter/material.dart';
import 'package:the_api/attachment.dart';
import 'package:the_api/post.dart';
import 'package:the_api/thread.dart';
import 'package:the_app/src/constants.dart';
import 'package:the_app/src/widgets/html.dart';
import 'package:the_app/src/widgets/image.dart';
import 'package:the_app/src/widgets/video_player.dart';

// try to match the paddings for a smooth curve
const _kPadding = kPadding;
const _kBorderRadius = _kPadding;

bool isTinhteFact(Thread thread) =>
    thread.threadImage != null &&
    (thread.threadTags?.values.fold<bool>(
          false,
          (prev, tagText) => prev || tagText == 'tinhtefact',
        ) ??
        false);

class TinhteFact extends StatelessWidget {
  final bool autoPlayVideo;
  final Post? post;
  final Thread thread;

  Post? get firstPost => post ?? thread.firstPost;

  const TinhteFact(
    this.thread, {
    this.autoPlayVideo = false,
    Key? key,
    this.post,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(_kPadding),
                  child: Text(
                    thread.threadTitle ?? '',
                    maxLines: null,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                _buildContents(),
                TinhteHtmlWidget(
                  "<center>${firstPost?.postBodyHtml ?? ''}</center>",
                  textStyle: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContents() {
    Attachment? threadImageAttachment;
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
        final videoUri = Uri.tryParse(videoUrl);
        if (videoUri != null) {
          return VideoPlayer(
            aspectRatio: aspectRatio,
            autoPlay: autoPlayVideo,
            uri: videoUri,
          );
        }
      }
    }

    return ThreadImageWidget.big(thread, thread.threadImage);
  }
}

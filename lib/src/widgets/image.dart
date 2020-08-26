import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:the_api/thread.dart';
import 'package:the_app/src/config.dart';

const kThreadImageAspectRatio = 594 / 368;

final String _apiUrlAttachments = "${config.apiRoot}?attachments";

Widget buildCachedNetworkImage(String imageUrl) => CachedNetworkImage(
      imageUrl: imageUrl,
      errorWidget: (_, __, ___) => const DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.grey,
        ),
      ),
      fit: BoxFit.cover,
    );

String getResizedUrl({
  @required String apiUrl,
  @required double boxWidth,
  @required double imageHeight,
  @required double imageWidth,
  int proxyPixelsMax = 50000000,
}) {
  if (apiUrl == null || boxWidth == null) return null;
  if (imageHeight == null || imageWidth == null) return null;
  if (!apiUrl.startsWith(_apiUrlAttachments)) return null;

  final proxyWidth = (boxWidth / 100).ceil() * 100;
  if (proxyWidth >= imageWidth) return null;

  if (proxyPixelsMax > 0) {
    final imageRatio = imageWidth / imageHeight;
    final proxyHeight = (proxyWidth / imageRatio).floor();
    if (proxyHeight * proxyWidth > proxyPixelsMax) return null;
  }

  return "$apiUrl&max_width=$proxyWidth";
}

class ThreadImageWidget extends StatelessWidget {
  final int threadId;
  final ThreadImage image;
  final ThreadImage placeholder;
  final bool useImageRatio;

  static final _smalls = Expando<ThreadImage>();

  ThreadImageWidget._({
    @required this.image,
    Key key,
    this.placeholder,
    @required this.threadId,
    this.useImageRatio = false,
  }) : super(key: key);

  factory ThreadImageWidget.small(Thread thread, ThreadImage image,
      {bool useImageRatio = false}) {
    _smalls[thread] = image;

    return ThreadImageWidget._(
      image: image,
      threadId: thread.threadId,
      useImageRatio: useImageRatio,
    );
  }

  factory ThreadImageWidget.big(Thread thread, ThreadImage image) =>
      ThreadImageWidget._(
        image: image,
        placeholder: _smalls[thread],
        threadId: thread.threadId,
        useImageRatio: true,
      );

  @override
  Widget build(BuildContext context) {
    final link = image?.link ?? '';

    if (link.isEmpty) {
      return DecoratedBox(
        decoration: BoxDecoration(color: Theme.of(context).backgroundColor),
        child: AspectRatio(aspectRatio: kThreadImageAspectRatio),
      );
    }

    final placeholder =
        this.placeholder != null && this.placeholder.link != link
            ? _buildImage(this.placeholder.link)
            : null;

    final img = _buildImage(
      link,
      frameBuilder: placeholder != null
          ? (_, child, frame, wasSynchronouslyLoaded) {
              if (wasSynchronouslyLoaded) return child;
              return frame != null ? child : placeholder;
            }
          : null,
    );

    return AspectRatio(
      aspectRatio: useImageRatio == true &&
              image.width != null &&
              image.height != null &&
              image.height != 0
          ? image.width / image.height
          : kThreadImageAspectRatio,
      child: threadId != null
          ? Hero(child: img, tag: "threadImageHero--$threadId")
          : img,
    );
  }

  /// Copies saved image from old thread to the new one.
  ///
  /// This is needed because internally an `[Expando]` is used
  /// to keep track of images without hogging memory.
  ///
  /// See [_smalls].
  static void syncImages(Thread oldThread, Thread newThread) =>
      _smalls[newThread] = _smalls[oldThread];

  static Widget _buildImage(String url, {ImageFrameBuilder frameBuilder}) =>
      Image(
        frameBuilder: frameBuilder,
        image: CachedNetworkImageProvider(url),
        fit: BoxFit.cover,
      );
}

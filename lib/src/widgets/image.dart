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

String? getResizedUrl({
  required String apiUrl,
  required double boxWidth,
  required double? imageHeight,
  required double? imageWidth,
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
  final ThreadImage? image;
  final ThreadImage? placeholder;
  final bool useImageRatio;

  static final _smalls = Expando<ThreadImage>();

  ThreadImageWidget._({
    required this.image,
    Key? key,
    this.placeholder,
    required this.threadId,
    this.useImageRatio = false,
  }) : super(key: key);

  factory ThreadImageWidget.small(Thread thread, ThreadImage? image,
      {bool useImageRatio = false}) {
    _smalls[thread] = image;

    return ThreadImageWidget._(
      image: image,
      threadId: thread.threadId,
      useImageRatio: useImageRatio,
    );
  }

  factory ThreadImageWidget.big(Thread thread, ThreadImage? image) =>
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

    final scopedPlaceholder = placeholder;
    final placeholderWidget =
        scopedPlaceholder != null && scopedPlaceholder.link != link
            ? _buildImage(scopedPlaceholder.link)
            : null;

    final img = _buildImage(
      link,
      frameBuilder: placeholderWidget != null
          ? (_, child, frame, wasSynchronouslyLoaded) {
              if (wasSynchronouslyLoaded) return child;
              return frame != null ? child : placeholderWidget;
            }
          : null,
    );

    final width = image?.width ?? 0;
    final height = image?.height ?? 0;

    return AspectRatio(
      aspectRatio: useImageRatio == true && width > 0 && height > 0
          ? width / height
          : kThreadImageAspectRatio,
      child: Hero(child: img, tag: "threadImageHero--$threadId"),
    );
  }

  static Widget _buildImage(String url, {ImageFrameBuilder? frameBuilder}) =>
      Image(
        frameBuilder: frameBuilder,
        image: CachedNetworkImageProvider(url),
        fit: BoxFit.cover,
      );
}

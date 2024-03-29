import 'package:flutter/material.dart';
import 'package:the_api/thread.dart';
import 'package:the_app/src/abstracts/cached_network_image.dart' as cached;
import 'package:the_app/src/config.dart';

const _kThreadImageAspectRatio = 594 / 368;

final String _apiUrlAttachments = "${config.apiRoot}?attachments";

String? getResizedUrl({
  required String apiUrl,
  required double boxWidth,
  required double imageHeight,
  required double imageWidth,
  int proxyPixelsMax = 50000000,
}) {
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

  const ThreadImageWidget._({
    required this.image,
    this.placeholder,
    required this.threadId,
    this.useImageRatio = false,
  });

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
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
        ),
        child: const AspectRatio(aspectRatio: _kThreadImageAspectRatio),
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
          : _kThreadImageAspectRatio,
      child: Hero(tag: "threadImageHero--$threadId", child: img),
    );
  }

  static Widget _buildImage(String url, {ImageFrameBuilder? frameBuilder}) =>
      Image(
        frameBuilder: frameBuilder,
        image: cached.image(url),
        fit: BoxFit.cover,
      );
}

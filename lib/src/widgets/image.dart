import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tinhte_api/thread.dart';

import '../config.dart';

const kThreadImageAspectRatio = 594 / 368;

const _apiUrlAttachments = "$configApiRoot?attachments";

String getResizedUrl({
  @required String apiUrl,
  double boxWidth,
  @required int imageHeight,
  @required int imageWidth,
  int proxyPixelsMax = 5000000,
}) {
  if (apiUrl == null || boxWidth == null) return null;
  if (imageHeight == null || imageWidth == null) return null;
  if (!apiUrl.startsWith(_apiUrlAttachments)) return null;

  /// finds the nearest power-of-2 value for proxy width
  /// e.g. boxWidth = 1000 -> log2(boxWidth) = 9.xxx -> proxyWidth = 2^10 = 1024
  final proxyWidth = pow(2, (log(boxWidth) / ln2).ceil());
  if (proxyWidth >= imageWidth) return null;

  if (proxyPixelsMax > 0) {
    final imageRatio = imageWidth / imageHeight;
    final proxyHeight = (proxyWidth / imageRatio).floor();
    if (proxyHeight * proxyWidth > proxyPixelsMax) return null;
  }

  return "$apiUrl&max_width=$proxyWidth";
}

Widget _buildImageWidget(
  String imageUrl, {
  String apiUrl,
  int imageHeight,
  int imageWidth,
}) =>
    LayoutBuilder(
      builder: (context, bc) {
        final mqd = MediaQuery.of(context);
        final resizedUrl = getResizedUrl(
          apiUrl: apiUrl ?? imageUrl,
          boxWidth: mqd.devicePixelRatio * mqd.size.width,
          imageHeight: imageHeight,
          imageWidth: imageWidth,
        );

        if (resizedUrl != null) debugPrint(resizedUrl);

        if (bc.maxWidth <= imageWidth) {
          return AspectRatio(
            aspectRatio: imageWidth / imageHeight,
            child: OverflowBox(
              child: SizedBox(
                child: Image(
                  image: CachedNetworkImageProvider(resizedUrl ?? imageUrl),
                  fit: BoxFit.cover,
                ),
                width: bc.maxWidth + 20,
                height: (bc.maxWidth + 20) / imageWidth * imageHeight,
              ),
            ),
          );
        }

        return SizedBox(
          child: Image(
            image: CachedNetworkImageProvider(resizedUrl ?? imageUrl),
            alignment: Alignment.topLeft,
            fit: BoxFit.contain,
          ),
          height: imageHeight.toDouble(),
          width: imageWidth.toDouble(),
        );
      },
    );

class AttachmentImageWidget extends StatelessWidget {
  final int height;
  final String permalink;
  final String src;
  final int width;

  AttachmentImageWidget({
    this.height,
    Key key,
    this.permalink,
    this.src,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (height == null || permalink == null || src == null || width == null) {
      return Container();
    }
    if (height < 1 || width < 1) {
      return Container();
    }

    return _buildImageWidget(
      permalink,
      apiUrl: src,
      imageHeight: height,
      imageWidth: width,
    );
  }
}

class ThreadImageWidget extends StatelessWidget {
  final int threadId;
  final ThreadImage image;

  ThreadImageWidget({
    @required this.image,
    Key key,
    @required this.threadId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final link = image?.link ?? '';

    if (link.isEmpty) {
      return DecoratedBox(
        decoration: BoxDecoration(color: Theme.of(context).backgroundColor),
        child: AspectRatio(aspectRatio: kThreadImageAspectRatio),
      );
    }

    final img = Image(
      image: CachedNetworkImageProvider(link),
      fit: BoxFit.cover,
    );

    return AspectRatio(
      aspectRatio: kThreadImageAspectRatio,
      child: threadId != null
          ? Hero(child: img, tag: "threadImageHero--$threadId")
          : img,
    );
  }
}

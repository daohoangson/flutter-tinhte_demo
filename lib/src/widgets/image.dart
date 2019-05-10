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

  final proxyWidth = (boxWidth / 100).ceil() * 100;
  if (proxyWidth >= imageWidth) return null;

  if (proxyPixelsMax > 0) {
    final imageRatio = imageWidth / imageHeight;
    final proxyHeight = (proxyWidth / imageRatio).floor();
    if (proxyHeight * proxyWidth > proxyPixelsMax) return null;
  }

  return "$apiUrl&max_width=$proxyWidth";
}

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
    if (permalink == null) return Container();
    if (height == null || height < 1) return Container();
    if (width == null || width < 1) return Container();

    return LayoutBuilder(
      builder: (context, bc) {
        final mqd = MediaQuery.of(context);
        final resizedUrl = getResizedUrl(
          apiUrl: src ?? permalink,
          boxWidth: mqd.devicePixelRatio * mqd.size.width,
          imageHeight: height,
          imageWidth: width,
        );

        if (resizedUrl != null) debugPrint(resizedUrl);

        final aspectRatio = AspectRatio(
          aspectRatio: width / height,
          child: Image(
            image: CachedNetworkImageProvider(resizedUrl ?? permalink),
            fit: BoxFit.cover,
          ),
        );

        if (bc.maxWidth < width) return aspectRatio;

        return Wrap(children: <Widget>[
          LimitedBox(
            child: aspectRatio,
            maxHeight: height.toDouble(),
            maxWidth: width.toDouble(),
          ),
        ]);
      },
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

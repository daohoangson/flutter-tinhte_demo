import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tinhte_api/thread.dart';

import '../config.dart';

const kThreadImageAspectRatio = 594 / 368;

const _apiUrlAttachments = "$configApiRoot?attachments";

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
        final imageUrl = getResizedUrl(
              apiUrl: src ?? permalink,
              boxWidth: mqd.devicePixelRatio * mqd.size.width,
              imageHeight: height,
              imageWidth: width,
            ) ??
            permalink;
        final image = CachedNetworkImageProvider(imageUrl);

        // image is large, just render it in aspect ratio
        if (bc.maxWidth < width)
          return AspectRatio(
            aspectRatio: width / height,
            child: Image(image: image, fit: BoxFit.cover),
          );

        // image is small, render with text padding for consistent look
        // put it in a wrap + limited box to prevent image from being scaled up
        return Padding(
          child: Wrap(children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: Image(
                image: image,
                fit: BoxFit.contain,
                width: width.toDouble(),
                height: height.toDouble(),
              ),
            ),
          ]),
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
        );
      },
    );
  }
}

class ThreadImageWidget extends StatelessWidget {
  final int threadId;
  final ThreadImage image;
  final bool useImageRatio;

  ThreadImageWidget({
    @required this.image,
    Key key,
    @required this.threadId,
    this.useImageRatio = false,
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
}

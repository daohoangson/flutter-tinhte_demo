import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tinhte_api/thread.dart';

const kThreadImageAspectRatio = 594 / 368;

Widget buildImageWidget(String imageUrl) => LayoutBuilder(
      builder: (context, bc) {
        final scale = MediaQuery.of(context).devicePixelRatio;
        final boxWidth = scale * bc.maxWidth;
        final proxyUrl = getProxyUrl(imageUrl, boxWidth);

        return CachedNetworkImage(
          imageUrl: proxyUrl,
          fit: BoxFit.cover,
        );
      },
    );

String getProxyUrl(String imageUrl, double boxWidth,
    {num imageWidth = 2048.0}) {
  if (boxWidth == null || boxWidth >= imageWidth) return imageUrl;
  if (imageUrl?.isNotEmpty != true) return imageUrl;
  if (!imageUrl.startsWith('https://photo2.tinhte.vn/')) return imageUrl;

  // find the nearest power of 2 proxy width
  // e.g. boxWidth = 1000 -> log2OfBoxWidth = 9.xxx -> proxyWidth = 2^10 = 1024
  final log2OfBoxWidth = log(boxWidth) / ln2;
  final proxyWidth = pow(2, log2OfBoxWidth.ceil());
  if (proxyWidth >= imageWidth) return imageUrl;

  return "https://data.tinhte.vn/imageproxy/${proxyWidth}x/$imageUrl";
}

class ThreadImageWidget extends StatelessWidget {
  final int threadId;
  final ThreadImage image;
  final Widget widgetOnNoImage;

  ThreadImageWidget({
    @required this.image,
    Key key,
    @required this.threadId,
    this.widgetOnNoImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final link = image?.link ?? '';

    if (link.isEmpty) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).backgroundColor,
        ),
        child: AspectRatio(
          aspectRatio: kThreadImageAspectRatio,
          child: widgetOnNoImage,
        ),
      );
    }

    final img = buildImageWidget(link);

    return AspectRatio(
      aspectRatio: kThreadImageAspectRatio,
      child: threadId != null
          ? Hero(
              tag: "threadImageHero--$threadId",
              child: img,
            )
          : img,
    );
  }
}

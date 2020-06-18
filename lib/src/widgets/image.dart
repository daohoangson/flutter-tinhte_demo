import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tinhte_api/thread.dart';
import 'package:tinhte_demo/src/config.dart';

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

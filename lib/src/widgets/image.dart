import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tinhte_api/thread.dart';

const kThreadImageAspectRatio = 594 / 368;

const _imageUrlPhoto2Prefix = 'https://photo2.tinhte.vn/';
const _imageUrlImageproxy = 'https://data.tinhte.vn/imageproxy';
const _imageUrlApiDataPrefix =
    'https://tinhte.vn/appforo/index.php?attachments';

String getResizedUrl({
  double boxWidth,
  @required int imageHeight,
  @required String imageUrl,
  @required int imageWidth,
  int proxyPixelsMax = 5000000,
}) {
  if (boxWidth == null || imageUrl == null) return null;
  if (imageHeight == null || imageWidth == null) return null;

  final isPhoto2 = imageUrl.startsWith(_imageUrlPhoto2Prefix);
  final isApiData = imageUrl.startsWith(_imageUrlApiDataPrefix);
  if (!isPhoto2 && !isApiData) return null;

  /// finds the nearest power-of-2 value for proxy width
  /// e.g. boxWidth = 1000 -> log2(boxWidth) = 9.xxx -> proxyWidth = 2^10 = 1024
  final proxyWidth = pow(2, (log(boxWidth) / ln2).ceil());
  if (proxyWidth >= imageWidth) return null;

  if (proxyPixelsMax > 0) {
    final imageRatio = imageWidth / imageHeight;
    final proxyHeight = (proxyWidth / imageRatio).floor();
    if (proxyHeight * proxyWidth > proxyPixelsMax) return null;
  }

  if (isPhoto2) return "$_imageUrlImageproxy/${proxyWidth}x/$imageUrl";
  if (isApiData) return "$imageUrl&max_width=$proxyWidth";
  return null;
}

Widget _buildImageWidget(String imageUrl, {num imageHeight, num imageWidth}) =>
    LayoutBuilder(
      builder: (context, bc) {
        final mqd = MediaQuery.of(context);
        final proxyUrl = getResizedUrl(
          boxWidth: mqd.devicePixelRatio * mqd.size.width,
          imageHeight: imageHeight,
          imageUrl: imageUrl,
          imageWidth: imageWidth,
        );

        return Image(
          image: CachedNetworkImageProvider(proxyUrl ?? imageUrl),
          fit: BoxFit.cover,
        );
      },
    );

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
        decoration: BoxDecoration(
          color: Theme.of(context).backgroundColor,
        ),
        child: AspectRatio(
          aspectRatio: kThreadImageAspectRatio,
        ),
      );
    }

    final img = _buildImageWidget(
      link,
      imageHeight: image.height,
      imageWidth: image.width,
    );

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

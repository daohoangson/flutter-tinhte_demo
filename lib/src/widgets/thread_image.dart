import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tinhte_api/thread.dart';

const ThreadImageAspectRatio = 594 / 368;

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
          aspectRatio: ThreadImageAspectRatio,
          child: widgetOnNoImage,
        ),
      );
    }

    final img = Image(
      image: CachedNetworkImageProvider(link),
      fit: BoxFit.cover,
    );

    return AspectRatio(
      aspectRatio: ThreadImageAspectRatio,
      child: threadId != null
          ? Hero(
              tag: "threadImageHero--$threadId",
              child: img,
            )
          : img,
    );
  }
}

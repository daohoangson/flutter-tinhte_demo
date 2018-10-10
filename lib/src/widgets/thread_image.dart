import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:tinhte_demo/api/model/thread.dart';

const ThreadImageAspectRatio = 594 / 368;

class ThreadImageWidget extends StatelessWidget {
  final ThreadImage image;

  ThreadImageWidget({Key key, @required this.image}) : super(key: key);

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
        ),
      );
    }

    return AspectRatio(
      aspectRatio: ThreadImageAspectRatio,
      child: Hero(
        tag: "threadImageHero-$link",
        child: CachedNetworkImage(
          imageUrl: link,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

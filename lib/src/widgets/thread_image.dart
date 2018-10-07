import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:tinhte_demo/api/model/thread.dart';

const ThreadImageAspectRatio = 594 / 368;

class ThreadImageWidget extends StatelessWidget {
  final ThreadImage image;

  ThreadImageWidget({Key key, @required this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) => AspectRatio(
        aspectRatio: ThreadImageAspectRatio,
        child: Hero(
          tag: "threadImageHero-${image.link}",
          child: CachedNetworkImage(
            imageUrl: image.link,
            fit: BoxFit.cover,
          ),
        ),
      );
}

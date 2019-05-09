import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tinhte_api/feature_page.dart';

import '../../constants.dart';

class FpHeader extends StatelessWidget {
  final FeaturePage fp;

  FpHeader(this.fp) : assert(fp != null);

  @override
  Widget build(BuildContext context) {
    if (fp.links?.image?.isNotEmpty != true) return Container();

    return AspectRatio(
      aspectRatio: kAspectRatioFpImage,
      child: Image(
        image: CachedNetworkImageProvider(fp.links.image),
        fit: BoxFit.cover,
      ),
    );
  }
}

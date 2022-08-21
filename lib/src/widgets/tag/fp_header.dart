import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:the_api/feature_page.dart';
import 'package:the_app/src/widgets/tag/follow_button.dart';
import 'package:the_app/src/intl.dart';

class FpHeader extends StatelessWidget {
  final FeaturePage fp;

  FpHeader(this.fp) : assert(fp != null);

  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
        _buildImage() ?? const SizedBox.shrink(),
        Row(
          children: <Widget>[
            Expanded(
              child: _buildStats(
                    context,
                    fp.values?.tagUseCount,
                    l(context).tagLowercaseDiscussions,
                  ) ??
                  const SizedBox.shrink(),
            ),
            Expanded(
              child: _buildStats(
                    context,
                    fp.values?.newsCount,
                    l(context).tagLowercaseNews,
                  ) ??
                  const SizedBox.shrink(),
            ),
            Expanded(
              flex: 2,
              child: FollowButton(fp),
            ),
          ],
        )
      ]);

  Widget? _buildImage() {
    final imageUrl = fp.links?.image ?? '';
    return imageUrl.isNotEmpty
        ? AspectRatio(
            aspectRatio: 114 / 44,
            child: Image(
              image: CachedNetworkImageProvider(imageUrl),
              fit: BoxFit.cover,
            ),
          )
        : null;
  }

  Widget? _buildStats(BuildContext context, int? value, String label) =>
      value != null
          ? Column(
              children: <Widget>[
                Text(
                  formatNumber(value),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                Text(label),
              ],
            )
          : null;
}

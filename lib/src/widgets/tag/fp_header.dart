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
              child: FollowButton(_FollowableFp(fp)),
            ),
          ],
        )
      ]);

  Widget _buildImage() => fp.links?.image?.isNotEmpty == true
      ? AspectRatio(
          aspectRatio: 114 / 44,
          child: Image(
            image: CachedNetworkImageProvider(fp.links.image),
            fit: BoxFit.cover,
          ),
        )
      : null;

  Widget _buildStats(BuildContext context, int value, String label) =>
      value != null
          ? Column(
              children: <Widget>[
                Text(
                  formatNumber(value),
                  style: TextStyle(color: Theme.of(context).accentColor),
                ),
                Text(label),
              ],
            )
          : null;
}

class _FollowableFp extends Followable {
  FeaturePage fp;

  _FollowableFp(this.fp);

  @override
  bool get isFollowed => fp.isFollowed;

  @override
  String get followersLink => fp.links?.follow;

  @override
  String get name => fp.fullName;

  @override
  set isFollowed(bool v) => fp = fp.copyWith(isFollowed: v);
}

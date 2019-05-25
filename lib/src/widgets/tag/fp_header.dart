import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tinhte_api/feature_page.dart';

import '../../api.dart';
import '../../intl.dart';

class FpHeader extends StatelessWidget {
  final FeaturePage fp;

  FpHeader(this.fp) : assert(fp != null);

  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
        _buildImage() ?? Container(),
        Row(
          children: <Widget>[
            Expanded(
              child: _buildStats(
                    context,
                    fp.values?.tagUseCount,
                    'discussions',
                  ) ??
                  Container(),
            ),
            Expanded(
              child: _buildStats(
                    context,
                    fp.values?.newsCount,
                    'news',
                  ) ??
                  Container(),
            ),
            Expanded(
              flex: 2,
              child: _FollowButton(fp),
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

class _FollowButton extends StatefulWidget {
  final FeaturePage fp;

  _FollowButton(this.fp) : assert(fp != null);

  @override
  State<StatefulWidget> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<_FollowButton> {
  var _isRequesting = false;

  bool get isFollowed => widget.fp.isFollowed == true;

  @override
  Widget build(BuildContext context) =>
      widget.fp.links?.follow?.isNotEmpty == true
          ? FlatButton(
              child: Text(isFollowed ? 'Unfollow' : 'Follow'),
              onPressed:
                  _isRequesting ? null : isFollowed ? _unfollow : _follow,
            )
          : Container();

  void _follow() => prepareForApiAction(context, () {
        if (_isRequesting) return;
        setState(() => _isRequesting = true);

        apiPost(
          ApiCaller.stateful(this),
          widget.fp.links.follow,
          onSuccess: (_) => setState(() => widget.fp.isFollowed = true),
          onComplete: () => setState(() => _isRequesting = false),
        );
      });

  void _unfollow() => prepareForApiAction(context, () {
        if (_isRequesting) return;
        setState(() => _isRequesting = true);

        apiDelete(
          ApiCaller.stateful(this),
          widget.fp.links.follow,
          onSuccess: (_) => setState(() => widget.fp.isFollowed = false),
          onComplete: () => setState(() => _isRequesting = false),
        );
      });
}

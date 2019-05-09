import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tinhte_api/tag.dart';

import '../../api.dart';
import '../../intl.dart';

class TagViewHeader extends StatelessWidget {
  final Tag tag;

  TagViewHeader(this.tag) : assert(tag != null);

  @override
  Widget build(BuildContext context) => Row(
        children: <Widget>[
          Expanded(
            child: _buildStats(context, tag.tagUseCount, 'discussions') ??
                Container(),
          ),
          Expanded(
            child: _FollowButton(tag),
          ),
        ],
      );

  Widget _buildStats(BuildContext context, int value, String label) =>
      value != null
          ? Text.rich(
              TextSpan(
                children: <TextSpan>[
                  TextSpan(
                    text: formatNumber(value),
                    style: TextStyle(color: Theme.of(context).accentColor),
                  ),
                  TextSpan(text: " $label"),
                ],
              ),
              textAlign: TextAlign.center,
            )
          : null;
}

class _FollowButton extends StatefulWidget {
  final Tag tag;

  _FollowButton(this.tag) : assert(tag != null);

  @override
  State<StatefulWidget> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<_FollowButton> {
  bool _isFetching = false;

  bool get isFollowed => widget.tag.tagIsFollowed == true;

  @override
  Widget build(BuildContext context) =>
      widget.tag.links?.followers?.isNotEmpty == true
          ? RaisedButton(
              child: Text(isFollowed ? 'Unfollow' : 'Follow'),
              onPressed: _isFetching ? null : isFollowed ? _unfollow : _follow,
            )
          : Container();

  void _follow() => prepareForApiAction(this, () {
        setState(() => _isFetching = true);
        apiPost(
          this,
          widget.tag.links.followers,
          onSuccess: (_) => setState(() => widget.tag.tagIsFollowed = true),
          onComplete: () => setState(() => _isFetching = false),
        );
      });

  void _unfollow() => prepareForApiAction(this, () {
        setState(() => _isFetching = true);
        apiDelete(
          this,
          widget.tag.links.followers,
          onSuccess: (_) => setState(() => widget.tag.tagIsFollowed = false),
          onComplete: () => setState(() => _isFetching = false),
        );
      });
}

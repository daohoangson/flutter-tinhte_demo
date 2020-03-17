import 'package:flutter/material.dart';
import 'package:tinhte_api/tag.dart';
import 'package:tinhte_demo/src/widgets/tag/follow_button.dart';
import 'package:tinhte_demo/src/intl.dart';

class TagViewHeader extends StatelessWidget {
  final Tag tag;

  TagViewHeader(this.tag) : assert(tag != null);

  @override
  Widget build(BuildContext context) => Row(
        children: <Widget>[
          Expanded(
            child: _buildStats(context, tag.tagUseCount, 'discussions') ??
                const SizedBox.shrink(),
          ),
          Expanded(child: FollowButton(_FollowableTag(tag))),
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

class _FollowableTag extends Followable {
  final Tag tag;

  _FollowableTag(this.tag);

  @override
  bool get isFollowed => tag.tagIsFollowed;

  @override
  String get followersLink => tag.links?.followers;

  @override
  String get name => "#${tag.tagText}";

  @override
  set isFollowed(bool v) => tag.tagIsFollowed = v;
}

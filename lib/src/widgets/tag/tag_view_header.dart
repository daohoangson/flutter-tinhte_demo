import 'package:flutter/material.dart';
import 'package:the_api/tag.dart';
import 'package:the_app/src/widgets/tag/follow_button.dart';
import 'package:the_app/src/intl.dart';

class TagViewHeader extends StatelessWidget {
  final Tag tag;

  TagViewHeader(this.tag);

  @override
  Widget build(BuildContext context) => Row(
        children: <Widget>[
          Expanded(
            child: _buildStats(context, tag.tagUseCount,
                    l(context).tagLowercaseDiscussions) ??
                const SizedBox.shrink(),
          ),
          Expanded(child: FollowButton(tag)),
        ],
      );

  Widget? _buildStats(BuildContext context, int? value, String label) =>
      value != null
          ? Text.rich(
              TextSpan(
                children: <TextSpan>[
                  TextSpan(
                    text: formatNumber(value),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  TextSpan(text: " $label"),
                ],
              ),
              textAlign: TextAlign.center,
            )
          : null;
}

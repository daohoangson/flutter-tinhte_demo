import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:the_api/user.dart';
import 'package:the_app/src/api.dart';
import 'package:the_app/src/intl.dart';
import 'package:the_app/src/widgets/tag/follow_button.dart';

class MemberViewHeader extends StatelessWidget {
  final User user;

  const MemberViewHeader(this.user, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(child: _buildInfo(context)),
                _buildStats(context),
              ],
            ),
            const Divider(),
            Row(
              children: <Widget>[
                Expanded(child: FollowButton(user)),
                Expanded(child: _IgnoreButton(user)),
              ],
            ),
          ],
        ),
      );

  Widget _buildInfo(BuildContext context) {
    final theme = Theme.of(context);
    final avatar = user.links?.avatarBig;

    return Row(
      children: <Widget>[
        CircleAvatar(
          backgroundImage:
              avatar != null ? CachedNetworkImageProvider(avatar) : null,
          radius: 30,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  user.username ?? '#${user.userId}',
                  style: theme.textTheme.subtitle1
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  "${l(context).userRegisterDate}: ${formatTimestamp(context, user.userRegisterDate)}",
                  style: theme.textTheme.caption,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStats(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.caption;
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(
              FontAwesomeIcons.solidMessage,
              color: theme.colorScheme.secondary,
              size: style?.fontSize,
            ),
            const SizedBox(width: 5),
            Text(
              formatNumber(user.userMessageCount),
              style: style,
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Icon(
              FontAwesomeIcons.solidHeart,
              color: theme.colorScheme.secondary,
              size: style?.fontSize,
            ),
            const SizedBox(width: 5),
            Text(
              formatNumber(user.userLikeCount),
              style: style,
            ),
          ],
        ),
      ],
    );
  }
}

class _IgnoreButton extends StatefulWidget {
  final User user;

  const _IgnoreButton(this.user);

  @override
  State<StatefulWidget> createState() => _IgnoreButtonState();
}

class _IgnoreButtonState extends State<_IgnoreButton> {
  var _isRequesting = false;

  User get user => widget.user;

  @override
  Widget build(BuildContext context) => user.links?.ignore?.isNotEmpty == true
      ? TextButton(
          onPressed: user.permissions?.ignore == true
              ? (_isRequesting
                  ? null
                  : user.userIsIgnored
                      ? _unignore
                      : _ignore)
              : null,
          child: Text(user.userIsIgnored
              ? l(context).userUnignore
              : l(context).userIgnore),
        )
      : const SizedBox.shrink();

  void _ignore() => prepareForApiAction(context, () {
        if (_isRequesting) return;

        final linkIgnore = user.links?.ignore ?? '';
        if (linkIgnore.isEmpty) return;

        setState(() => _isRequesting = true);

        apiPost(
          ApiCaller.stateful(this),
          linkIgnore,
          onSuccess: (_) => setState(() => user.userIsIgnored = true),
          onComplete: () => setState(() => _isRequesting = false),
        );
      });

  void _unignore() => prepareForApiAction(context, () {
        if (_isRequesting) return;

        final linkIgnore = user.links?.ignore ?? '';
        if (linkIgnore.isEmpty) return;

        setState(() => _isRequesting = true);

        apiDelete(
          ApiCaller.stateful(this),
          linkIgnore,
          onSuccess: (_) => setState(() => user.userIsIgnored = false),
          onComplete: () => setState(() => _isRequesting = false),
        );
      });
}

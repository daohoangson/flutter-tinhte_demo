import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tinhte_api/user.dart';

import '../../api.dart';
import '../../intl.dart';

class MemberViewHeader extends StatelessWidget {
  final User user;

  MemberViewHeader(this.user) : assert(user != null);

  @override
  Widget build(BuildContext context) => Padding(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(child: _buildInfo(context)),
                _buildStats(context),
              ],
            ),
            Divider(),
            Row(
              children: <Widget>[
                Expanded(child: _FollowButton(user)),
                Expanded(child: _IgnoreButton(user)),
              ],
            ),
          ],
        ),
        padding: const EdgeInsets.all(10),
      );

  Widget _buildInfo(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: <Widget>[
        CircleAvatar(
          backgroundImage: CachedNetworkImageProvider(
            user.links?.avatarBig,
          ),
          radius: 30,
        ),
        Expanded(
          child: Padding(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  user.username,
                  style: theme.textTheme.subhead
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  "Joined: ${formatTimestamp(user.userRegisterDate)}",
                  style: theme.textTheme.caption,
                ),
              ],
            ),
            padding: const EdgeInsets.all(5),
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
              FontAwesomeIcons.solidCommentAlt,
              color: theme.accentColor,
              size: style.fontSize,
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
              color: theme.accentColor,
              size: style.fontSize,
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

class _FollowButton extends StatefulWidget {
  final User user;

  _FollowButton(this.user) : assert(user != null);

  @override
  State<StatefulWidget> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<_FollowButton> {
  bool _isFetching = false;

  bool get isFollowed => widget.user.userIsFollowed == true;

  @override
  Widget build(BuildContext context) =>
      widget.user.links?.followers?.isNotEmpty == true
          ? FlatButton(
              child: Text(isFollowed ? 'Unfollow' : 'Follow'),
              onPressed: widget.user.permissions?.follow == true
                  ? (_isFetching ? null : isFollowed ? _unfollow : _follow)
                  : null,
            )
          : Container();

  void _follow() => prepareForApiAction(this, () {
        setState(() => _isFetching = true);
        apiPost(
          this,
          widget.user.links.followers,
          onSuccess: (_) => setState(() => widget.user.userIsFollowed = true),
          onComplete: () => setState(() => _isFetching = false),
        );
      });

  void _unfollow() => prepareForApiAction(this, () {
        setState(() => _isFetching = true);
        apiDelete(
          this,
          widget.user.links.followers,
          onSuccess: (_) => setState(() => widget.user.userIsFollowed = false),
          onComplete: () => setState(() => _isFetching = false),
        );
      });
}

class _IgnoreButton extends StatefulWidget {
  final User user;

  _IgnoreButton(this.user) : assert(user != null);

  @override
  State<StatefulWidget> createState() => _IgnoreButtonState();
}

class _IgnoreButtonState extends State<_IgnoreButton> {
  bool _isFetching = false;

  bool get isIgnored => widget.user.userIsIgnored == true;

  @override
  Widget build(BuildContext context) =>
      widget.user.links?.ignore?.isNotEmpty == true
          ? FlatButton(
              child: Text(isIgnored ? 'Unignore' : 'Ignore'),
              onPressed: widget.user.permissions?.ignore == true
                  ? (_isFetching ? null : isIgnored ? _unignore : _ignore)
                  : null,
            )
          : Container();

  void _ignore() => prepareForApiAction(this, () {
        setState(() => _isFetching = true);
        apiPost(
          this,
          widget.user.links.ignore,
          onSuccess: (_) => setState(() => widget.user.userIsIgnored = true),
          onComplete: () => setState(() => _isFetching = false),
        );
      });

  void _unignore() => prepareForApiAction(this, () {
        setState(() => _isFetching = true);
        apiDelete(
          this,
          widget.user.links.ignore,
          onSuccess: (_) => setState(() => widget.user.userIsIgnored = false),
          onComplete: () => setState(() => _isFetching = false),
        );
      });
}

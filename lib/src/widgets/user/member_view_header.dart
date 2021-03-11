import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:the_api/user.dart';
import 'package:the_app/src/api.dart';
import 'package:the_app/src/intl.dart';
import 'package:the_app/src/widgets/tag/follow_button.dart';

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
                Expanded(child: FollowButton(_FollowableUser(user))),
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
                  style: theme.textTheme.subtitle1
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  "${l(context).userRegisterDate}: ${formatTimestamp(context, user.userRegisterDate)}",
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

class _FollowableUser extends Followable {
  User user;

  _FollowableUser(this.user);

  @override
  bool get isFollowed => user.userIsFollowed;

  @override
  String get followersLink => user.links?.followers;

  @override
  String get name => user.username;

  @override
  set isFollowed(bool v) => user = user.copyWith(userIsFollowed: v);

  @override
  String labelFollow(BuildContext context) => l(context).userFollow;

  @override
  String labelFollowing(BuildContext context) => l(context).userUnfollow;
}

class _IgnoreButton extends StatefulWidget {
  final User user;

  _IgnoreButton(this.user) : assert(user != null);

  @override
  State<StatefulWidget> createState() => _IgnoreButtonState();
}

class _IgnoreButtonState extends State<_IgnoreButton> {
  bool _isIgnored;
  var _isRequesting = false;

  @override
  void initState() {
    super.initState();
    _isIgnored = widget.user.userIsIgnored == true;
  }

  @override
  Widget build(BuildContext context) =>
      widget.user.links?.ignore?.isNotEmpty == true
          ? TextButton(
              child: Text(
                  _isIgnored ? l(context).userUnignore : l(context).userIgnore),
              onPressed: widget.user.permissions?.ignore == true
                  ? (_isRequesting
                      ? null
                      : _isIgnored
                          ? _unignore
                          : _ignore)
                  : null,
            )
          : Container();

  void _ignore() => prepareForApiAction(context, () {
        if (_isRequesting) return;
        setState(() => _isRequesting = true);

        apiPost(
          ApiCaller.stateful(this),
          widget.user.links.ignore,
          onSuccess: (_) => setState(() => _isIgnored = true),
          onComplete: () => setState(() => _isRequesting = false),
        );
      });

  void _unignore() => prepareForApiAction(context, () {
        if (_isRequesting) return;
        setState(() => _isRequesting = true);

        apiDelete(
          ApiCaller.stateful(this),
          widget.user.links.ignore,
          onSuccess: (_) => setState(() => _isIgnored = false),
          onComplete: () => setState(() => _isRequesting = false),
        );
      });
}

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:the_api/followable.dart';
import 'package:the_api/user.dart';
import 'package:the_app/src/api.dart';
import 'package:the_app/src/intl.dart';

class FollowButton extends StatefulWidget {
  final Followable followable;

  const FollowButton(this.followable, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _FollowState();
}

class _FollowState extends State<FollowButton> {
  bool _alert = false;
  bool _email = false;
  bool _hasOptions = false;
  bool _isRequesting = false;

  Followable get f => widget.followable;

  bool get hasLink => f.followersLink?.isNotEmpty == true;

  @override
  void initState() {
    super.initState();

    if (f.isFollowed != true || !hasLink) return;
    apiGet(
      ApiCaller.stateful(this),
      f.followersLink!,
      onSuccess: (json) {
        final usersValue = json['users'];
        final users = usersValue is List ? usersValue : [];
        if (users.length != 1) return;
        final userValue = users[0];
        final user = userValue is Map ? userValue : {};

        final userId = user['user_id'];
        final visitor = context.read<User>();
        if (visitor.userId != userId) return;

        final followValue = user['follow'];
        final follow = followValue is Map ? followValue : {};
        var alert = _alert;
        var email = _email;
        if (follow.containsKey('alert')) alert = follow['alert'] == true;
        if (follow.containsKey('email')) email = follow['email'] == true;

        setState(() {
          _alert = alert;
          _email = email;
          _hasOptions = true;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) => !hasLink
      ? const SizedBox.shrink()
      : f.isFollowed != true
          ? _buildButtonFollow()
          : _buildButtonFollowing();

  Widget _buildButtonFollow() => TextButton(
        onPressed: _isRequesting ? null : () => _follow(_FollowOptions()),
        child: Text(l(context).follow),
      );

  Widget _buildButtonFollowing() => Row(
        children: <Widget>[
          Expanded(
            child: ElevatedButton(
              onPressed: _isRequesting ? null : _unfollow,
              child: Text(l(context).followFollowing),
            ),
          ),
          IconButton(
            icon: Icon(_alert || _email
                ? FontAwesomeIcons.bell
                : FontAwesomeIcons.bellSlash),
            onPressed: !_hasOptions || _isRequesting ? null : _changeOptions,
          ),
        ],
      );

  void _follow(_FollowOptions options) {
    prepareForApiAction(context, () {
      if (_isRequesting) return;
      setState(() => _isRequesting = true);

      apiPost(
        ApiCaller.stateful(this),
        f.followersLink!,
        bodyFields: {
          'alert': options.alert ? '1' : '0',
          'email': options.email ? '1' : '0',
        },
        onSuccess: (_) => setState(() {
          f.isFollowed = true;
          _alert = options.alert;
          _email = options.email;
          _hasOptions = true;
        }),
        onComplete: () => setState(() => _isRequesting = false),
      );
    });
  }

  void _unfollow() async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l(context).followUnfollowXQuestion(f.name)),
        actions: <Widget>[
          TextButton(
            child: Text(lm(context).cancelButtonLabel),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            child: Text(lm(context).okButtonLabel),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    if (_isRequesting) return;
    setState(() => _isRequesting = true);

    apiDelete(
      ApiCaller.stateful(this),
      f.followersLink!,
      onSuccess: (_) => setState(() => f.isFollowed = false),
      onComplete: () => setState(() => _isRequesting = false),
    );
  }

  void _changeOptions() async {
    final options = await showDialog<_FollowOptions>(
      context: context,
      builder: (_) =>
          _FollowOptionsDialog(f, _FollowOptions(alert: _alert, email: _email)),
    );

    if (options == null) return;
    _follow(options);
  }
}

class _FollowOptionsDialog extends StatefulWidget {
  final _FollowOptions fo;
  final Followable followable;

  const _FollowOptionsDialog(this.followable, this.fo, {Key? key})
      : super(key: key);

  @override
  State<_FollowOptionsDialog> createState() => _FollowOptionsState();
}

class _FollowOptionsState extends State<_FollowOptionsDialog> {
  bool _alert = false;
  bool _email = false;

  Followable get f => widget.followable;

  @override
  void initState() {
    super.initState();
    _alert = widget.fo.alert;
    _email = widget.fo.email;
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(l(context).followNotificationChannels),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(l(context).followNotificationChannelExplainForX(f.name)),
            CheckboxListTile(
              onChanged: (v) => setState(() => _alert = v == true),
              title: Text(l(context).followNotificationChannelAlert),
              value: _alert,
            ),
            CheckboxListTile(
              onChanged: (v) => setState(() => _email = v == true),
              title: Text(l(context).followNotificationChannelEmail),
              value: _email,
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: Text(lm(context).cancelButtonLabel),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            child: Text(lm(context).continueButtonLabel),
            onPressed: () => Navigator.of(context).pop(_FollowOptions(
              alert: _alert,
              email: _email,
            )),
          ),
        ],
      );
}

class _FollowOptions {
  final bool alert;
  final bool email;

  _FollowOptions({this.alert = true, this.email = false});
}

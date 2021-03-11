import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:the_api/user.dart';
import 'package:the_app/src/api.dart';
import 'package:the_app/src/intl.dart';

class FollowButton extends StatefulWidget {
  final Followable followable;

  FollowButton(this.followable) : assert(followable != null);

  @override
  State<StatefulWidget> createState() => _FollowState();
}

class _FollowState extends State<FollowButton> {
  var _alert = false;
  var _email = false;
  var _hasOptions = false;
  var _isRequesting = false;

  Followable get f => widget.followable;

  @override
  void initState() {
    super.initState();

    if (f.isFollowed != true || !f.hasFollowersLink()) return;
    apiGet(
      ApiCaller.stateful(this),
      f.followersLink,
      onSuccess: (json) {
        if (!json.containsKey('users')) return;
        final List users = json['users'];
        if (users.length != 1) return;
        final Map<String, dynamic> user = users[0];

        if (!user.containsKey('user_id')) return;
        final int userId = user['user_id'];
        final visitor = context.read<User>();
        if (visitor.userId != userId) return;

        if (!user.containsKey('follow')) return;
        final Map<String, dynamic> follow = user['follow'];
        var alert = _alert;
        var email = _email;
        if (follow.containsKey('alert')) alert = follow['alert'];
        if (follow.containsKey('email')) email = follow['email'];

        setState(() {
          _alert = alert;
          _email = email;
          _hasOptions = true;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) => !f.hasFollowersLink()
      ? const SizedBox.shrink()
      : f.isFollowed != true
          ? _buildButtonFollow()
          : _buildButtonFollowing();

  Widget _buildButtonFollow() => TextButton(
        child: Text(f.labelFollow(context)),
        onPressed: _isRequesting ? null : _follow,
      );

  Widget _buildButtonFollowing() => Row(
        children: <Widget>[
          Expanded(
            child: ElevatedButton(
              child: Text(f.labelFollowing(context)),
              onPressed: _isRequesting ? null : _unfollow,
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

  void _follow([_FollowOptions options]) {
    final alert = options?.alert != false;
    final email = options?.email == true;

    prepareForApiAction(context, () {
      if (_isRequesting || !f.hasFollowersLink()) return;
      setState(() => _isRequesting = true);

      apiPost(
        ApiCaller.stateful(this),
        f.followersLink,
        bodyFields: {
          'alert': alert ? '1' : '0',
          'email': email ? '1' : '0',
        },
        onSuccess: (_) => setState(() {
          f.isFollowed = true;
          _alert = alert;
          _email = email;
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
        content: Text(f.labelUnfollowXQuestion(context)),
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

    if (_isRequesting || !f.hasFollowersLink()) return;
    setState(() => _isRequesting = true);

    apiDelete(
      ApiCaller.stateful(this),
      f.followersLink,
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

abstract class Followable {
  bool get isFollowed;
  String get followersLink;
  String get name;

  set isFollowed(bool v);

  bool hasFollowersLink() => followersLink?.isNotEmpty == true;

  String labelFollow(BuildContext context) => l(context).tagFollow;

  String labelFollowing(BuildContext context) => l(context).tagFollowing;

  String labelNotificationChannels(BuildContext context) =>
      l(context).tagNotificationChannels;

  String labelNotificationChannelAlert(BuildContext context) =>
      l(context).tagNotificationChannelAlert;

  String labelNotificationChannelEmail(BuildContext context) =>
      l(context).tagNotificationChannelEmail;

  String labelNotificationChannelExplainForX(BuildContext context) =>
      l(context).tagNotificationChannelExplainForX(name);

  String labelUnfollowXQuestion(BuildContext context) =>
      l(context).tagUnfollowXQuestion(name);
}

class _FollowOptionsDialog extends StatefulWidget {
  final _FollowOptions fo;
  final Followable followable;

  const _FollowOptionsDialog(this.followable, this.fo, {Key key})
      : super(key: key);

  @override
  State<_FollowOptionsDialog> createState() => _FollowOptionsState();
}

class _FollowOptionsState extends State<_FollowOptionsDialog> {
  var _alert = false;
  var _email = false;

  Followable get f => widget.followable;

  @override
  void initState() {
    super.initState();
    _alert = widget.fo.alert;
    _email = widget.fo.email;
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(f.labelNotificationChannels(context)),
        content: Column(
          children: <Widget>[
            Text(f.labelNotificationChannelExplainForX(context)),
            CheckboxListTile(
              onChanged: (v) => setState(() => _alert = v),
              title: Text(f.labelNotificationChannelAlert(context)),
              value: _alert,
            ),
            CheckboxListTile(
              onChanged: (v) => setState(() => _email = v),
              title: Text(f.labelNotificationChannelEmail(context)),
              value: _email,
            ),
          ],
          mainAxisSize: MainAxisSize.min,
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

  _FollowOptions({this.alert, this.email});
}

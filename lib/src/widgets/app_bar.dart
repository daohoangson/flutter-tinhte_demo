import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tinhte_api/user.dart';

import '../screens/login.dart';
import '../screens/notification_list.dart';
import '../api.dart';
import '../constants.dart';
import '../push_notification.dart';
import '../responsive_layout.dart';

class AppBarDrawerHeader extends StatelessWidget {
  AppBarDrawerHeader({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final apiData = ApiData.of(context);
    final hasToken = apiData.hasToken;
    final user = apiData.user;

    return DrawerHeader(
      decoration: BoxDecoration(
        color: Theme.of(context).highlightColor,
      ),
      child: hasToken
          ? user != null
              ? _buildVisitorPanel(context, user)
              : const Text('Welcome back, we are loading user profile...')
          : GestureDetector(
              child: const Text('Login'),
              onTap: () => pushLoginScreen(context),
            ),
    );
  }

  Widget _buildVisitorPanel(BuildContext context, User user) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1.0,
                child: CircleAvatar(
                  backgroundImage:
                      CachedNetworkImageProvider(user.links?.avatarBig),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: RichText(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(
                    text: user.username ?? '',
                    style: Theme.of(context).textTheme.title.copyWith(
                          color: Theme.of(context).accentColor,
                        ),
                  ),
                  TextSpan(
                    text: " ${user.rank?.rankName ?? ''}",
                    style: Theme.of(context).textTheme.subhead.copyWith(
                          color: kColorUserRank,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
}

class AppBarDrawerFooter extends StatelessWidget {
  AppBarDrawerFooter({Key key}) : super(key: key);

  Widget build(BuildContext context) => ApiData.of(context).hasToken
      ? ListTile(
          title: const Text('Logout'),
          onTap: () => logout(context),
        )
      : Container(height: 0.0, width: 0.0);
}

class AppBarMenuIconButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final rs = ResponsiveState.of(context);

    return rs?.hasDrawer() == true
        ? IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => rs?.openDrawer(),
          )
        : Container();
  }
}

class AppBarNotificationButton extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AppBarNotificationButtonState();
}

class _AppBarNotificationButtonState extends State<AppBarNotificationButton> {
  int _unread = 0;
  StreamSubscription<int> _unreadSub;

  @override
  void initState() {
    super.initState();
    _unreadSub = listenToUnread((unread) => setState(() => _unread = unread));
  }

  @override
  void dispose() {
    _unreadSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_unread == 0) {
      return IconButton(
        icon: Icon(Icons.notifications_none),
        onPressed: _showNotificationList,
      );
    }

    return Stack(
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.notifications),
          onPressed: _showNotificationList,
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.topRight,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text(_unread > 99 ? '99+' : "$_unread"),
              ),
            ),
          ),
        )
      ],
    );
  }

  _showNotificationList() => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => NotificationListScreen()),
      );
}

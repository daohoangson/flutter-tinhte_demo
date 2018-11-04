import 'dart:async';
import 'package:flutter/material.dart';

import '../../screens/notification_list.dart';
import '../../push_notification.dart';

class HomeNotificationAppBarButton extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeNotificationAppBarButtonState();
}

class _HomeNotificationAppBarButtonState
    extends State<HomeNotificationAppBarButton> {
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

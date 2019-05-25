import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:tinhte_api/user.dart';

import 'config.dart';
import 'link.dart';

final _firebaseMessaging = FirebaseMessaging();

final StreamController<int> _notifController = StreamController.broadcast();

final StreamController<PushNotificationUnread> _unreadController =
    StreamController.broadcast();

StreamSubscription<int> listenToNotification(void onData(int notificationId)) =>
    _notifController.stream.listen(onData);

_notifControllerAddFromFcmMessage(Map data) {
  if (!data.containsKey('notification_id')) return;
  final str = data['notification_id'] as String;
  final notificationId = int.parse(str);

  debugPrint("_notifControllerAddFromFcmMessage: "
      "notificationId=$notificationId");
  _notifController.sink.add(notificationId);
}

_unreadControllerAddFromFcmMessage(Map data) {
  if (!data.containsKey('user_unread_notification_count')) return;
  final str = data['user_unread_notification_count'] as String;
  final value = int.parse(str);

  debugPrint("_unreadControllerAddFromFcmMessage: value=$value");
  _unreadController.sink.add(PushNotificationUnread(value));
}

class PushNotificationApp extends StatefulWidget {
  final Widget child;
  final GlobalKey<NavigatorState> primaryNavKey;

  PushNotificationApp({
    this.child,
    Key key,
    this.primaryNavKey,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PushNotificationAppState();
}

class _PushNotificationAppState extends State<PushNotificationApp> {
  String _fcmToken;
  User _user;

  String get fcmToken {
    if (_fcmToken != null) return _fcmToken;

    _firebaseMessaging.requestNotificationPermissions();

    _firebaseMessaging
        .getToken()
        .then((token) => setState(() => _fcmToken = token));

    return null;
  }

  @override
  void initState() {
    super.initState();

    _firebaseMessaging.configure(
      onLaunch: _onLaunchOrResume,
      onMessage: (m) {
        debugPrint("FCM.onMessage: $m");
        final data = m.containsKey('data') ? m['data'] as Map : m;
        _notifControllerAddFromFcmMessage(data);
        _unreadControllerAddFromFcmMessage(data);
      },
      onResume: _onLaunchOrResume,
    );
  }

  @override
  Widget build(BuildContext _) => Consumer<User>(
        builder: (_, user, __) {
          if (user.userUnreadNotificationCount != null)
            _unreadController.sink
                .add(PushNotificationUnread(user.userUnreadNotificationCount));

          final existingUserId = _user?.userId ?? 0;
          if (existingUserId > 0 && user.userId == 0) {
            _unregister();
          }
          _user = user;

          return MultiProvider(
            providers: [
              Provider<PushNotificationToken>.value(
                value: PushNotificationToken(this),
              ),
              StreamProvider<PushNotificationUnread>.value(
                initialData: PushNotificationUnread(0),
                stream: _unreadController.stream,
              ),
            ],
            child: widget.child,
          );
        },
      );

  Future _onLaunchOrResume(Map m) {
    debugPrint("FCM._onLaunchOrResume: $m");
    final data = m.containsKey('data') ? m['data'] as Map : m;

    // TODO: use message.data.links.content when it is available
    if (!data.containsKey('notification_id')) return Future.value(false);
    final id = data['notification_id'];

    return parseLink(
      widget.primaryNavKey.currentState.context,
      path: "notifications/content?notification_id=$id",
    );
  }

  void _unregister() async {
    if (_fcmToken?.isNotEmpty != true) return;

    final url = "$configPushServer/unregister";

    final response = await http.post(
      url,
      body: {
        'device_type': 'firebase',
        'device_id': _fcmToken,
        'oauth_client_id': configClientId,
      },
    );

    if (response.statusCode == 200) {
      debugPrint("Unregistered $_fcmToken at $url...");
    } else {
      debugPrint("Failed unregistering $_fcmToken: "
          "status=${response.statusCode}, body=${response.body}");
    }
  }
}

class PushNotificationToken {
  final _PushNotificationAppState _pnas;

  PushNotificationToken(this._pnas);

  String get value => _pnas.fcmToken;
}

class PushNotificationUnread {
  final int value;

  PushNotificationUnread(this.value);
}

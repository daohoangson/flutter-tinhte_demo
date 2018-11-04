import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:tinhte_api/notification.dart' as api;
import 'package:tinhte_api/user.dart';

import 'api.dart';

final _firebaseMessaging = FirebaseMessaging();

final StreamController<int> _notifController = StreamController.broadcast();

final StreamController<int> _unreadController = StreamController.broadcast();

StreamSubscription<int> listenToNotification(void onData(int notificationId)) =>
    _notifController.stream.listen(onData);

StreamSubscription<int> listenToUnread(void onData(int unread)) =>
    _unreadController.stream.listen(onData);

_notifControllerAddFromFcmMessage(Map<String, dynamic> message) {
  if (!message.containsKey('data')) return;
  final data = message['data'] as Map;

  if (!data.containsKey('notification_id')) return;
  final str = data['notification_id'] as String;
  final notificationId = int.parse(str);

  debugPrint("_notifControllerAddFromFcmMessage: "
      "notificationId=$notificationId");
  _notifController.sink.add(notificationId);
}

_unreadControllerAddFromFcmMessage(Map<String, dynamic> message) {
  if (!message.containsKey('data')) return;
  final data = message['data'] as Map;

  if (!data.containsKey('user_unread_notification_count')) return;
  final str = data['user_unread_notification_count'] as String;
  final value = int.parse(str);

  debugPrint("_unreadControllerAddFromFcmMessage: value=$value");
  _unreadController.sink.add(value);
}

class PushNotificationApp extends StatefulWidget {
  final Widget child;
  final String fcmProjectId;
  final String pushServer;

  PushNotificationApp({
    @required this.child,
    @required this.fcmProjectId,
    Key key,
    @required this.pushServer,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PushNotificationAppState();
}

class _PushNotificationAppState extends State<PushNotificationApp> {
  String _fcmToken;
  User _user;

  @override
  void initState() {
    super.initState();

    _firebaseMessaging.configure(
      onLaunch: (message) {
        debugPrint("FCM.onLaunch: $message");
      },
      onMessage: (message) {
        debugPrint("FCM.onMessage: $message");
        _notifControllerAddFromFcmMessage(message);
        _unreadControllerAddFromFcmMessage(message);
      },
      onResume: (message) {
        debugPrint("FCM.onResume: $message");
      },
    );

    _firebaseMessaging.getToken().then((token) => setState(() {
          _fcmToken = token;
          _subscribeIfPossible();
        }));
  }

  @override
  Widget build(BuildContext context) {
    final user = ApiData.of(context).user;
    _unreadController.sink.add(user?.userUnreadNotificationCount ?? 0);

    final userId = user?.userId ?? 0;
    if (userId > 0 && userId != _user?.userId) {
      _user = user;
      _subscribeIfPossible();

      // for iOS only, this is a no op on Android
      _firebaseMessaging.requestNotificationPermissions();
    }

    return widget.child;
  }

  void _subscribeIfPossible() {
    if (_fcmToken?.isNotEmpty != true) return;
    if (_user?.userId?.isFinite != true) return;

    final apiData = ApiData.of(context);
    final api = apiData.api;
    final token = apiData.token?.accessToken;
    if (token?.isNotEmpty != true) return;

    final url = "${widget.pushServer}/subscribe";
    final hubUri = "${api.apiRoot}?subscriptions";
    final hubTopic = "user_notification_${_user.userId}";

    http.post(
      url,
      body: {
        'device_type': 'firebase',
        'device_id': _fcmToken,
        'hub_uri': hubUri,
        'hub_topic': hubTopic,
        'oauth_client_id': api.clientId,
        'oauth_token': token,
        'extra_data[platform]': Theme.of(context).platform.toString(),
        'extra_data[project]': widget.fcmProjectId,
      },
    ).then((response) {
      if (response.statusCode == 202) {
        debugPrint("Subscribed at $url for $hubUri/$hubTopic...");
      } else {
        print(response.statusCode);
        print(response.body);
      }
    }).catchError((e) => print(e));
  }
}

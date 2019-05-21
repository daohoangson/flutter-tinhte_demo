import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:tinhte_api/user.dart';

import 'api.dart';
import 'config.dart';
import 'link.dart';

final _firebaseMessaging = FirebaseMessaging();

final StreamController<int> _notifController = StreamController.broadcast();

final StreamController<int> _unreadController = StreamController.broadcast();

StreamSubscription<int> listenToNotification(void onData(int notificationId)) =>
    _notifController.stream.listen(onData);

StreamSubscription<int> listenToUnread(void onData(int unread)) =>
    _unreadController.stream.listen(onData);

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
  _unreadController.sink.add(value);
}

class PushNotificationApp extends StatefulWidget {
  final Widget child;

  PushNotificationApp(this.child, {Key key}) : super(key: key);

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
      onLaunch: _onLaunchOrResume,
      onMessage: (m) {
        debugPrint("FCM.onMessage: $m");
        final data = m.containsKey('data') ? m['data'] as Map : m;
        _notifControllerAddFromFcmMessage(data);
        _unreadControllerAddFromFcmMessage(data);
      },
      onResume: _onLaunchOrResume,
    );

    _firebaseMessaging.getToken().then((token) => setState(() {
          _fcmToken = token;
          _subscribe();
        }));
  }

  @override
  Widget build(BuildContext context) {
    final user = ApiData.of(context).user;
    _unreadController.sink.add(user?.userUnreadNotificationCount ?? 0);

    final userId = user?.userId ?? 0;
    final existingUserId = _user?.userId ?? 0;
    if (userId != existingUserId) {
      if (userId > 0) {
        _user = user;
        _subscribe();

        // for iOS only, this is a no op on Android
        _firebaseMessaging.requestNotificationPermissions();
      } else if (existingUserId > 0) {
        _user = null;
        _unregister();
      }
    }

    return widget.child;
  }

  Future _onLaunchOrResume(Map m) {
    debugPrint("FCM._onLaunchOrResume: $m");
    final data = m.containsKey('data') ? m['data'] as Map : m;

    // TODO: use message.data.links.content when it is available
    if (!data.containsKey('notification_id')) return Future.value(false);
    final id = data['notification_id'];

    return parseLink(this, path: "notifications/content?notification_id=$id");
  }

  void _subscribe() async {
    if (_fcmToken?.isNotEmpty != true) return;
    if (_user?.userId?.isFinite != true) return;

    final apiData = ApiData.of(context);
    final api = apiData.api;
    final token = apiData.token?.accessToken;
    if (token?.isNotEmpty != true) return;

    final url = "$configPushServer/subscribe";
    final hubUri = "${api.apiRoot}?subscriptions";
    final hubTopic = "user_notification_${_user.userId}";

    final response = await http.post(
      url,
      body: {
        'device_type': 'firebase',
        'device_id': _fcmToken,
        'hub_uri': hubUri,
        'hub_topic': hubTopic,
        'oauth_client_id': api.clientId,
        'oauth_token': token,
        'extra_data[click_action]': 'FLUTTER_NOTIFICATION_CLICK',
        'extra_data[notification]': '1',
        'extra_data[platform]': Theme.of(context).platform.toString(),
        'extra_data[project]': configFcmProjectId,
      },
    );

    if (response.statusCode == 202) {
      debugPrint("Subscribed $_fcmToken at $url for $hubUri/$hubTopic...");
    } else {
      debugPrint("Failed subscribing $_fcmToken: "
          "status=${response.statusCode}, body=${response.body}");
    }
  }

  void _unregister() async {
    if (_fcmToken?.isNotEmpty != true) return;

    final url = "$configPushServer/unregister";

    final response = await http.post(
      url,
      body: {
        'device_type': 'firebase',
        'device_id': _fcmToken,
        'oauth_client_id': ApiData.of(context).api.clientId,
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

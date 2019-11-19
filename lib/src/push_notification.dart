import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:tinhte_api/user.dart';

import 'screens/notification_list.dart';
import 'config.dart';
import 'link.dart';

const _kUnreadIconSize = 30.0;
const _kUnreadIconBoxSize = 50.0;

final _firebaseMessaging = FirebaseMessaging();

final StreamController<int> _notifController = StreamController.broadcast();

StreamSubscription<int> listenToNotification(void onData(int notificationId)) =>
    _notifController.stream.listen(onData);

void _notifControllerAddFromFcmMessage(Map data) {
  if (!data.containsKey('notification_id')) return;
  final str = data['notification_id'] as String;
  final notificationId = int.parse(str);

  debugPrint("_notifControllerAddFromFcmMessage: "
      "notificationId=$notificationId");
  _notifController.sink.add(notificationId);
}

class PushNotificationApp extends StatefulWidget {
  final Widget child;
  final GlobalKey<NavigatorState> primaryNavKey;

  PushNotificationApp({
    @required this.child,
    Key key,
    @required this.primaryNavKey,
  })  : assert(child != null),
        assert(primaryNavKey != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() => _PushNotificationAppState();
}

class _PushNotificationAppState extends State<PushNotificationApp> {
  final _pnt = PushNotificationToken();

  User _user;

  var _unread = 0;
  var _unreadIsVisible = false;
  final _unreadDismissibleKey = UniqueKey();

  @override
  void initState() {
    super.initState();

    _firebaseMessaging.configure(
      onLaunch: _onLaunchOrResume,
      onMessage: _onMessage,
      onResume: _onLaunchOrResume,
    );
  }

  @override
  Widget build(BuildContext _) => Consumer<User>(
        builder: (_, user, __) {
          final existingUserId = _user?.userId ?? 0;
          final newUserId = user?.userId ?? 0;
          if (newUserId != existingUserId) {
            if (existingUserId > 0 && user.userId == 0) {
              _unread = 0;
              _unregister();
            } else {
              if (user.userUnreadNotificationCount != null) {
                _unread = user.userUnreadNotificationCount;
                _unreadIsVisible = _unread > 0;
              }
            }
          }
          _user = user;

          return ChangeNotifierProvider<PushNotificationToken>.value(
            child: Directionality(
              child: Stack(
                children: <Widget>[
                  widget.child,
                  _unread > 0 && _unreadIsVisible
                      ? Positioned(
                          top: kToolbarHeight,
                          right: kToolbarHeight / 2,
                          child: _buildUnreadIcon(),
                        )
                      : const SizedBox.shrink(),
                ],
              ),
              textDirection: TextDirection.ltr,
            ),
            value: _pnt,
          );
        },
      );

  Widget _buildUnreadIcon() => Dismissible(
        child: GestureDetector(
          child: Container(
            child: _UnreadIcon(),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_kUnreadIconBoxSize),
              color: Colors.redAccent,
            ),
            height: _kUnreadIconBoxSize,
            width: _kUnreadIconBoxSize,
          ),
          onTap: () {
            widget.primaryNavKey.currentState?.push(
              MaterialPageRoute(builder: (_) => NotificationListScreen()),
            );
            setState(() => _unreadIsVisible = false);
          },
        ),
        key: _unreadDismissibleKey,
        onDismissed: (_) => setState(() => _unreadIsVisible = false),
      );

  Future<bool> _onLaunchOrResume(Map<String, dynamic> message) async {
    debugPrint("FCM._onLaunchOrResume: $message");
    final Map d = message.containsKey('data') ? message['data'] : message;
    if (!d.containsKey('notification_id')) return false;

    // TODO: use message.data.links.content when it is available
    final p = "notifications/content?notification_id=${d['notification_id']}";

    final navigator = widget.primaryNavKey.currentState;
    if (navigator == null) return false;

    return parseLink(path: p, rootNavigator: navigator);
  }

  Future<bool> _onMessage(Map<String, dynamic> message) async {
    debugPrint("FCM.onMessage: $message");
    final Map data = message.containsKey('data') ? message['data'] : message;
    _notifControllerAddFromFcmMessage(data);

    if (!data.containsKey('user_unread_notification_count')) return false;
    final str = data['user_unread_notification_count'] as String;
    final value = int.parse(str);
    if (value == _unread) return false;

    _unreadIsVisible = value > 0;
    if (mounted) {
      setState(() => _unread = value);
    } else {
      _unread = value;
    }
    return true;
  }

  void _unregister() async {
    final _fcmToken = _pnt._value;
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

class PushNotificationToken extends ChangeNotifier {
  String _value;

  PushNotificationToken();

  String get value {
    if (_value != null) return _value;

    _firebaseMessaging.requestNotificationPermissions();

    _firebaseMessaging.getToken().then((token) {
      _value = token;
      notifyListeners();
    });

    return null;
  }
}

class _UnreadIcon extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _UnreadIconState();
}

class _UnreadIconState extends State<_UnreadIcon>
    with TickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      lowerBound: .0,
      upperBound: .1,
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RotationTransition(
        turns: _controller,
        child: Icon(
          Icons.notifications_none,
          color: Colors.white70,
          size: _kUnreadIconSize,
        ),
      );
}

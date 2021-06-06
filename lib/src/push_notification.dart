import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:the_api/user.dart';
import 'package:the_app/src/screens/notification_list.dart';
import 'package:the_app/src/config.dart';
import 'package:the_app/src/link.dart';

const _kUnreadIconSize = 30.0;
const _kUnreadIconBoxSize = 50.0;

final primaryNavKey = GlobalKey<NavigatorState>();

final _firebaseMessaging = FirebaseMessaging.instance;
final _key = GlobalKey<_PushNotificationAppState>();
final StreamController<int> _notifController = StreamController.broadcast();

void configureFcm() {
  FirebaseMessaging.onMessage.listen(_onMessage);
  FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);
}

StreamSubscription<int> listenToNotification(void onData(int notificationId)) =>
    _notifController.stream.listen(onData);

Future<String> getInitialPath() async {
  try {
    final message = await _firebaseMessaging.getInitialMessage();
    if (message == null) return null;

    final path = _getContentLink(message.data);
    if (path != null) {
      debugPrint('push_notification getInitialPath() -> $path');
    }

    return path;
  } catch (e) {
    print(e);
  }

  return null;
}

String _getContentLink(Map<String, dynamic> message) {
  final Map d = message.containsKey('data') ? message['data'] : message;
  if (!d.containsKey('notification_id')) return null;

  // TODO: use message.data.links.content when it is available
  return "notifications/content?notification_id=${d['notification_id']}";
}

void _notifControllerAddFromFcmMessage(Map data) {
  if (!data.containsKey('notification_id')) return;
  final notificationId = int.tryParse(data['notification_id']);

  debugPrint("_notifControllerAddFromFcmMessage: "
      "notificationId=$notificationId");
  if (notificationId != null) _notifController.sink.add(notificationId);
}

Future<bool> _onMessage(RemoteMessage message) async {
  debugPrint("FCM.onMessage: $message");
  final Map data =
      message.data.containsKey('data') ? message.data['data'] : message.data;
  _notifControllerAddFromFcmMessage(data);

  final pnas = _key.currentState;
  if (pnas == null || !data.containsKey('user_unread_notification_count'))
    return false;

  final value = int.tryParse(data['user_unread_notification_count']);
  if (value == null) return false;

  return pnas._setUnread(value);
}

Future<bool> _onMessageOpenedApp(RemoteMessage message) async {
  debugPrint("FCM._onResume: $message");
  final path = _getContentLink(message.data);
  final navigator = primaryNavKey.currentState;
  if (navigator == null || path == null) return false;

  return parsePath(
    path,
    rootNavigator: navigator,
    defaultWidget: const NotificationListScreen(),
  );
}

class PushNotificationApp extends StatefulWidget {
  final Widget child;

  PushNotificationApp({@required this.child})
      : assert(child != null),
        super(key: _key);

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
            primaryNavKey.currentState?.push(
              MaterialPageRoute(builder: (_) => NotificationListScreen()),
            );
            setState(() => _unreadIsVisible = false);
          },
        ),
        key: _unreadDismissibleKey,
        onDismissed: (_) => setState(() => _unreadIsVisible = false),
      );

  bool _setUnread(int value) {
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

    final url = "${config.pushServer}/unregister";
    final response = await http.post(
      Uri.parse(url),
      body: {'registration_token': _fcmToken},
    );

    if (response.statusCode == 202) {
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

    _firebaseMessaging.requestPermission();

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

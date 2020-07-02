import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:tinhte_api/user.dart';
import 'package:tinhte_demo/src/screens/notification_list.dart';
import 'package:tinhte_demo/src/api.dart';
import 'package:tinhte_demo/src/config.dart';
import 'package:tinhte_demo/src/link.dart';

const _kUnreadIconSize = 30.0;
const _kUnreadIconBoxSize = 50.0;

final primaryNavKey = GlobalKey<NavigatorState>();

final _firebaseMessaging = FirebaseMessaging();
final _key = GlobalKey<_PushNotificationAppState>();
final StreamController<int> _notifController = StreamController.broadcast();

Map<String, dynamic> _onLaunchMessage;

void configureFcm() => _firebaseMessaging.configure(
      onLaunch: _onLaunch,
      onMessage: _onMessage,
      onResume: _onResume,
    );

StreamSubscription<int> listenToNotification(void onData(int notificationId)) =>
    _notifController.stream.listen(onData);

Widget onLaunchMessageWidgetOr(Widget fallback) {
  if (_onLaunchMessage == null) return fallback;

  final path = _getContentLink(_onLaunchMessage);
  if (path == null) return fallback;

  return _OnLaunchMessageWidget(path, fallback: fallback);
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

Future<bool> _onLaunch(Map<String, dynamic> message) async {
  debugPrint("FCM._onLaunch: $message");
  _onLaunchMessage = message;
  return true;
}

Future<bool> _onMessage(Map<String, dynamic> message) async {
  debugPrint("FCM.onMessage: $message");
  final Map data = message.containsKey('data') ? message['data'] : message;
  _notifControllerAddFromFcmMessage(data);

  final pnas = _key.currentState;
  if (pnas == null || !data.containsKey('user_unread_notification_count'))
    return false;

  final value = int.tryParse(data['user_unread_notification_count']);
  if (value == null) return false;

  return pnas._setUnread(value);
}

Future<bool> _onResume(Map<String, dynamic> message) async {
  debugPrint("FCM._onResume: $message");
  final path = _getContentLink(message);
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
      url,
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

    _firebaseMessaging.requestNotificationPermissions();

    _firebaseMessaging.getToken().then((token) {
      _value = token;
      notifyListeners();
    });

    return null;
  }
}

class _OnLaunchMessageWidget extends StatefulWidget {
  final Widget fallback;
  final String path;

  _OnLaunchMessageWidget(this.path, {this.fallback, Key key})
      : assert(path != null),
        assert(fallback != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() => _OnLaunchMessageState();
}

class _OnLaunchMessageState extends State<_OnLaunchMessageWidget> {
  var _fallback = false;
  Future<Widget> _future;

  @override
  void initState() {
    super.initState();

    _future = buildWidget(
      ApiCaller.stateful(this),
      widget.path,
      defaultWidget: const NotificationListScreen(),
    ).catchError((error) async {
      await showApiErrorDialog(context, error);
      setState(() => _fallback = true);
    });
  }

  @override
  Widget build(BuildContext _) => _fallback
      ? widget.fallback
      : FutureBuilder<Widget>(
          builder: (__, snapshot) => snapshot.hasData
              ? snapshot.data
              : const Center(child: CircularProgressIndicator()),
          future: _future,
        );
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

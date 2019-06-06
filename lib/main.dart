import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

import 'src/screens/home.dart';
import 'src/api.dart';
import 'src/push_notification.dart';

void main() {
  FlutterError.onError = (e) => Crashlytics.instance.onError(e);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static final _primaryNavKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) => ApiApp(
        child: PushNotificationApp(
          child: MaterialApp(
            title: 'Tinh tế Demo',
            theme: ThemeData(brightness: Brightness.dark),
            home: Navigator(
              key: _primaryNavKey,
              onGenerateRoute: (_) => HomeScreenRoute(),
            ),
          ),
          primaryNavKey: _primaryNavKey,
        ),
      );
}

import 'dart:async';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

import 'src/screens/home.dart';
import 'src/api.dart';
import 'src/push_notification.dart';

void main() {
  FlutterError.onError = Crashlytics.instance.recordFlutterError;

  runZoned<Future<void>>(() async {
    runApp(MyApp());
  }, onError: Crashlytics.instance.recordError);
}

class MyApp extends StatelessWidget {
  static final _primaryNavKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) => ApiApp(
        child: PushNotificationApp(
          child: MaterialApp(
            title: 'Tinh tế Demo',
            theme: ThemeData(brightness: Brightness.dark),
            navigatorKey: _primaryNavKey,
            home: HomeScreen(),
          ),
          primaryNavKey: _primaryNavKey,
        ),
      );
}

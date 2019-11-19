import 'dart:async';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'src/screens/home.dart';
import 'src/widgets/menu/dark_theme.dart';
import 'src/api.dart';
import 'src/push_notification.dart';

void main() {
  FlutterError.onError = Crashlytics.instance.recordFlutterError;

  runZoned<Future<void>>(() async {
    final darkTheme = await DarkTheme.create();
    runApp(MyApp(darkTheme: darkTheme));
  }, onError: Crashlytics.instance.recordError);
}

class MyApp extends StatelessWidget {
  final DarkTheme darkTheme;
  final primaryNavKey = GlobalKey<NavigatorState>();

  MyApp({this.darkTheme});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider<DarkTheme>.value(
        child: Consumer<DarkTheme>(builder: (_, __, ___) => _buildApp()),
        value: darkTheme,
      );

  Widget _buildApp() => ApiApp(
        child: PushNotificationApp(
          child: MaterialApp(
            darkTheme: _theme(_themeDark),
            home: HomeScreen(),
            key: ValueKey("darkTheme=${darkTheme.value}"),
            navigatorKey: primaryNavKey,
            theme: _theme(_themeLight),
            title: 'Tinh tế Demo',
          ),
          primaryNavKey: primaryNavKey,
        ),
      );

  ThemeData _theme(ThemeData fallback()) {
    switch (darkTheme.value) {
      case false:
        return _themeLight();
      case true:
        return _themeDark();
    }
    return fallback();
  }

  ThemeData _themeDark() => ThemeData(brightness: Brightness.dark);
  ThemeData _themeLight() => ThemeData(brightness: Brightness.light);
}

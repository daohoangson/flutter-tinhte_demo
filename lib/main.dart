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
    runApp(MyApp());
  }, onError: Crashlytics.instance.recordError);
}

class MyApp extends StatelessWidget {
  final primaryNavKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider<DarkTheme>.value(
        child: Consumer<DarkTheme>(
          builder: (_, darkTheme, __) => _buildApp(
            darkTheme: darkTheme.value,
          ),
        ),
        value: DarkTheme(),
      );

  Widget _buildApp({
    bool darkTheme,
  }) =>
      ApiApp(
        child: PushNotificationApp(
          child: MaterialApp(
            darkTheme: _theme(darkTheme, _themeDark),
            home: HomeScreen(),
            key: ValueKey("darkTheme=$darkTheme"),
            navigatorKey: primaryNavKey,
            theme: _theme(darkTheme, _themeLight),
            title: 'Tinh tế Demo',
          ),
          primaryNavKey: primaryNavKey,
        ),
      );

  ThemeData _theme(bool darkTheme, ThemeData fallback()) => darkTheme == false
      ? _themeLight()
      : darkTheme == true ? _themeDark() : fallback();

  ThemeData _themeDark() => ThemeData(brightness: Brightness.dark);
  ThemeData _themeLight() => ThemeData(brightness: Brightness.light);
}

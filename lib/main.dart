import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:the_app/src/abstracts/error_reporting.dart' as error_reporting;
import 'package:the_app/src/abstracts/firebase.dart' as firebase;
import 'package:the_app/src/intl.dart';
import 'package:the_app/src/screens/home.dart';
import 'package:the_app/src/widgets/font_control.dart';
import 'package:the_app/src/widgets/menu/dark_theme.dart';
import 'package:the_app/src/widgets/dismiss_keyboard.dart';
import 'package:the_app/src/api.dart';
import 'package:the_app/src/push_notification.dart';
import 'package:timeago/timeago.dart' as timeago;

void main() async {
  timeago.setLocaleMessages('vi', timeago.ViMessages());

  WidgetsFlutterBinding.ensureInitialized();
  await firebase.initializeApp();
  configurePushNotification();

  error_reporting.runZoned<Future<void>>(() async {
    final values = await Future.wait([
      DarkTheme.create(),
      FontScale.create(),
      onLaunchMessageWidgetOr(HomeScreen()),
    ]);

    runApp(MyApp(
      darkTheme: values[0],
      fontScale: values[1],
      home: values[2],
    ));
  });
}

class MyApp extends StatelessWidget {
  final DarkTheme darkTheme;
  final FontScale fontScale;
  final Widget home;

  MyApp({
    this.darkTheme,
    this.fontScale,
    this.home,
  });

  @override
  Widget build(BuildContext context) => MultiProvider(
        child: Consumer<DarkTheme>(builder: (_, __, ___) => _buildApp()),
        providers: [
          ChangeNotifierProvider<DarkTheme>.value(value: darkTheme),
          ChangeNotifierProvider<FontScale>.value(value: fontScale),
        ],
      );

  Widget _buildApp() => ApiApp(
        child: PushNotificationApp(
          child: DismissKeyboard(
            MaterialApp(
              darkTheme: _theme(_themeDark),
              home: home,
              localizationsDelegates: [
                const L10nDelegate(),
                GlobalCupertinoLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
              ],
              navigatorKey: primaryNavKey,
              navigatorObservers: [FontControlWidget.routeObserver],
              onGenerateTitle: (context) => l(context).appTitle,
              supportedLocales: [
                const Locale('en', ''),
                const Locale('vi', ''),
              ],
              theme: _theme(_themeLight),
            ),
          ),
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

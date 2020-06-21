import 'dart:async';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:tinhte_demo/src/intl.dart';
import 'package:tinhte_demo/src/screens/home.dart';
import 'package:tinhte_demo/src/widgets/font_control.dart';
import 'package:tinhte_demo/src/widgets/menu/dark_theme.dart';
import 'package:tinhte_demo/src/widgets/dismiss_keyboard.dart';
import 'package:tinhte_demo/src/api.dart';
import 'package:tinhte_demo/src/push_notification.dart';

void main() {
  timeago.setLocaleMessages('vi', timeago.ViMessages());

  FlutterError.onError = Crashlytics.instance.recordFlutterError;

  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    configureFcm();

    final darkTheme = await DarkTheme.create();
    final fontScale = await FontScale.create();
    runApp(MyApp(
      darkTheme: darkTheme,
      fontScale: fontScale,
    ));
  }, Crashlytics.instance.recordError);
}

class MyApp extends StatelessWidget {
  final DarkTheme darkTheme;
  final FontScale fontScale;

  MyApp({
    this.darkTheme,
    this.fontScale,
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
              home: onLaunchMessageWidgetOr(HomeScreen()),
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

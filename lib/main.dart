import 'dart:async';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:tinhte_demo/src/intl.dart';
import 'package:tinhte_demo/src/screens/home.dart';
import 'package:tinhte_demo/src/widgets/menu/dark_theme.dart';
import 'package:tinhte_demo/src/widgets/dismiss_keyboard.dart';
import 'package:tinhte_demo/src/api.dart';
import 'package:tinhte_demo/src/push_notification.dart';

void main() {
  FlutterError.onError = Crashlytics.instance.recordFlutterError;

  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    configureFcm();

    final darkTheme = await DarkTheme.create();
    runApp(MyApp(darkTheme: darkTheme));
  }, Crashlytics.instance.recordError);
}

class MyApp extends StatelessWidget {
  final DarkTheme darkTheme;

  MyApp({this.darkTheme});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider<DarkTheme>.value(
        child: Consumer<DarkTheme>(builder: (_, __, ___) => _buildApp()),
        value: darkTheme,
      );

  Widget _buildApp() => ApiApp(
        child: PushNotificationApp(
          child: DismissKeyboard(
            MaterialApp(
              darkTheme: _theme(_themeDark),
              home: onLaunchMessageWidgetOr(HomeScreen()),
              key: ValueKey("darkTheme=${darkTheme.value}"),
              localizationsDelegates: [
                const L10nDelegate(),
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
              ],
              navigatorKey: primaryNavKey,
              onGenerateTitle: (BuildContext context) => L10n.of(context).title,
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

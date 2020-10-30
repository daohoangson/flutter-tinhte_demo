import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
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
  await Firebase.initializeApp();
  configureFcm();

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  runZonedGuarded<Future<void>>(() async {
    final darkTheme = await DarkTheme.create();
    final fontScale = await FontScale.create();
    runApp(MyApp(
      darkTheme: darkTheme,
      fontScale: fontScale,
    ));
  }, FirebaseCrashlytics.instance.recordError);
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

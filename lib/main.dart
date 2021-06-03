import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:the_app/src/intl.dart';
import 'package:the_app/src/screens/home.dart';
import 'package:the_app/src/screens/notification_list.dart';
import 'package:the_app/src/widgets/font_control.dart';
import 'package:the_app/src/widgets/menu/dark_theme.dart';
import 'package:the_app/src/widgets/dismiss_keyboard.dart';
import 'package:the_app/src/api.dart';
import 'package:the_app/src/push_notification.dart' as push_notification;
import 'package:the_app/src/uni_links.dart' as uni_links;
import 'package:the_app/src/widgets/on_launch_widget.dart';
import 'package:timeago/timeago.dart' as timeago;

void main() async {
  timeago.setLocaleMessages('vi', timeago.ViMessages());

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  push_notification.configureFcm();

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  runZonedGuarded<Future<void>>(() async {
    final values = await Future.wait([
      DarkTheme.create(),
      FontScale.create(),
      push_notification.getInitialPath(),
      uni_links.getInitialPath(),
    ]);

    String initialPath;
    Widget defaultWidget;
    if (values[2] != null) {
      initialPath = values[2];
      defaultWidget = NotificationListScreen();
    } else if (values[3] != null) {
      initialPath = values[3];
    }
    final home = HomeScreen();

    runApp(MyApp(
      darkTheme: values[0],
      fontScale: values[1],
      home: initialPath != null
          ? OnLaunchWidget(
              initialPath,
              defaultWidget: defaultWidget,
              fallbackWidget: home,
            )
          : home,
    ));
  }, FirebaseCrashlytics.instance.recordError);
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
        child: push_notification.PushNotificationApp(
          child: uni_links.UniLinksApp(
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
                navigatorKey: push_notification.primaryNavKey,
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

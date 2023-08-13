import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:the_app/src/abstracts/error_reporting.dart' as error_reporting;
import 'package:the_app/src/abstracts/facebook_log_in.dart' as facebook_log_in;
import 'package:the_app/src/abstracts/firebase.dart' as firebase;
import 'package:the_app/src/intl.dart';
import 'package:the_app/src/link.dart';
import 'package:the_app/src/screens/home.dart';
import 'package:the_app/src/screens/initial_path.dart';
import 'package:the_app/src/screens/notification_list.dart';
import 'package:the_app/src/widgets/font_control.dart';
import 'package:the_app/src/widgets/menu/dark_theme.dart';
import 'package:the_app/src/widgets/dismiss_keyboard.dart';
import 'package:the_app/src/api.dart';
import 'package:the_app/src/push_notification.dart' as push_notification;
import 'package:the_app/src/widgets/menu/dev_tools.dart';
import 'package:timeago/timeago.dart' as timeago;

void main() async {
  timeago.setLocaleMessages('vi', timeago.ViMessages());

  DarkTheme? darkTheme;
  DevTools? devTools;
  FontScale? fontScale;
  String? initialPath;
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([
    DarkTheme.create().then((value) => darkTheme = value),
    FontScale.create().then((value) => fontScale = value),
    DevTools.create().then((value) => devTools = value),
    facebook_log_in.configureFacebookLogin(),
    firebase.initializeApp().then((value) async {
      error_reporting.configureErrorReporting();
      push_notification.configurePushNotification();
      initialPath = await push_notification.getInitialPath();
    }),
  ]);

  Widget home;
  if (initialPath != null) {
    home = InitialPathScreen(
      initialPath!,
      defaultWidget: const NotificationListScreen(),
    );
  } else {
    home = HomeScreen();
  }

  runApp(MyApp(
    darkTheme: darkTheme!,
    devTools: devTools!,
    fontScale: fontScale!,
    home: home,
  ));
}

class MyApp extends StatelessWidget {
  final DarkTheme darkTheme;
  final DevTools devTools;
  final FontScale fontScale;
  final Widget home;

  const MyApp({
    required this.darkTheme,
    required this.devTools,
    required this.fontScale,
    Key? key,
    required this.home,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: [
          ChangeNotifierProvider<DarkTheme>.value(value: darkTheme),
          ChangeNotifierProvider<DevTools>.value(value: devTools),
          ChangeNotifierProvider<FontScale>.value(value: fontScale),
        ],
        child: Builder(builder: (context) => _buildApp(context)),
      );

  Widget _buildApp(BuildContext context) {
    context.watch<DarkTheme>();
    final showPerformanceOverlay = context.select<DevTools, bool>(
        (DevTools devTools) => devTools.showPerformanceOverlay);

    Widget app = MaterialApp(
      darkTheme: _theme(_themeDark),
      localizationsDelegates: const [
        L10nDelegate(),
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      navigatorKey: push_notification.primaryNavKey,
      navigatorObservers: [FontControlWidget.routeObserver],
      onGenerateTitle: (context) => l(context).appTitle,
      onGenerateInitialRoutes: (_) => [MaterialPageRoute(builder: (_) => home)],
      onGenerateRoute: (settings) {
        final name = settings.name;
        if (name == null) {
          debugPrint('onGenerateRoute -> $settings without name');
          return null;
        }

        debugPrint('onGenerateRoute -> $settings');
        parsePath(
          buildToolsParseLinkPath(name),
          rootNavigator: push_notification.primaryNavKey.currentState,
        );
        return null;
      },
      showPerformanceOverlay: showPerformanceOverlay,
      supportedLocales: const [
        Locale('en', ''),
        Locale('vi', ''),
      ],
      theme: _theme(_themeLight),
    );

    app = DismissKeyboard(app);
    app = push_notification.PushNotificationApp(child: app);
    app = ApiApp(child: app);

    return app;
  }

  ThemeData _theme(ThemeData Function() fallback) {
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

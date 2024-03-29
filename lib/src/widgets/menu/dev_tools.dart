import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_app/src/abstracts/error_reporting.dart' as error_reporting;
import 'package:the_app/src/constants.dart';
import 'package:the_app/src/intl.dart';

import 'availability/error_reporting.dart';
import 'availability/firebase.dart';
import 'availability/push_notification.dart';

abstract class DevTools extends ChangeNotifier {
  bool get isDeveloper;
  set isDeveloper(bool v);

  bool get showPerformanceOverlay;
  set showPerformanceOverlay(bool v);

  static Future<DevTools> create() async {
    final developer = _DevTools();
    final prefs = await SharedPreferences.getInstance();
    developer._isDeveloper = prefs.getBool(kPrefKeyDevToolIsDeveloper);
    developer._showPerformanceOverlay =
        prefs.getBool(kPrefKeyDevToolShowPerformanceOverlay);
    return developer;
  }
}

class _DevTools extends ChangeNotifier implements DevTools {
  bool? _isDeveloper;
  bool? _showPerformanceOverlay;

  @override
  bool get isDeveloper => _isDeveloper == true;

  @override
  set isDeveloper(bool v) {
    _isDeveloper = v;
    notifyListeners();

    SharedPreferences.getInstance()
        .then((prefs) => prefs.setBool(kPrefKeyDevToolIsDeveloper, v));
  }

  @override
  bool get showPerformanceOverlay => _showPerformanceOverlay == true;

  @override
  set showPerformanceOverlay(bool v) {
    _showPerformanceOverlay = v;
    notifyListeners();

    SharedPreferences.getInstance().then(
        (prefs) => prefs.setBool(kPrefKeyDevToolShowPerformanceOverlay, v));
  }
}

class DeveloperMenu extends StatelessWidget {
  const DeveloperMenu({super.key});

  @override
  Widget build(BuildContext context) => Consumer<DevTools>(
        builder: (_, developer, __) => developer.isDeveloper
            ? ListTile(
                title: Text(l(context).menuDeveloper),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const DeveloperMenuScreen())),
              )
            : const SizedBox.shrink(),
      );
}

class DeveloperMenuScreen extends StatelessWidget {
  const DeveloperMenuScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(l(context).menuDeveloper),
        ),
        body: ListView(
          children: <Widget>[
            const ErrorReportingWidget(),
            const FirebaseWidget(),
            const PushNotificationWidget(),
            _ShowPerformanceOverlayWidget(),
            _CrashTestWidget(),
          ],
        ),
      );
}

class _CrashTestWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ListTile(
        title: Text(l(context).menuDeveloperCrashTest),
        onTap: () => error_reporting.crash(),
      );
}

class _ShowPerformanceOverlayWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Consumer<DevTools>(
        builder: (_, devTools, __) => ListTile(
          leading: Checkbox(
            onChanged: (value) => _updateValue(context, value),
            value: devTools.showPerformanceOverlay,
          ),
          title: Text(l(context).menuDeveloperShowPerformanceOverlay),
          onTap: () => _updateValue(context),
        ),
      );

  void _updateValue(BuildContext context, [bool? value]) {
    final devTools = context.read<DevTools>();
    devTools.showPerformanceOverlay = value ?? !devTools.showPerformanceOverlay;
  }
}

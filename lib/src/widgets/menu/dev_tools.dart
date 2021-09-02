import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_app/src/abstracts/error_reporting.dart' as error_reporting;
import 'package:the_app/src/constants.dart';
import 'package:the_app/src/intl.dart';

import 'availability/error_reporting.dart';
import 'availability/firebase.dart';
import 'availability/push_notification.dart';
import 'availability/uni_links.dart';

class DevTools extends ChangeNotifier {
  bool _isDeveloper;

  DevTools._();

  bool get isDeveloper => _isDeveloper == true;

  set isDeveloper(bool v) {
    _isDeveloper = v;
    notifyListeners();

    SharedPreferences.getInstance().then((prefs) => v == null
        ? prefs.remove(kPrefKeyDevToolIsDeveloper)
        : prefs.setBool(kPrefKeyDevToolIsDeveloper, _isDeveloper));
  }

  static Future<DevTools> create() async {
    final developer = DevTools._();
    final prefs = await SharedPreferences.getInstance();
    developer._isDeveloper = prefs.getBool(kPrefKeyDevToolIsDeveloper);
    return developer;
  }
}

class DeveloperMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Consumer<DevTools>(
        builder: (_, developer, __) => developer.isDeveloper
            ? ListTile(
                title: Text(l(context).menuDeveloper),
                onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => DeveloperMenuScreen())),
              )
            : const SizedBox.shrink(),
      );
}

class DeveloperMenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(l(context).menuDeveloper),
        ),
        body: ListView(
          children: <Widget>[
            ErrorReportingWidget(),
            FirebaseWidget(),
            PushNotificationWidget(),
            UniLinksWidget(),
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

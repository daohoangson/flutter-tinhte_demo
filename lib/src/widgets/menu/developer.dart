import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_app/src/abstracts/error_reporting.dart' as error_reporting;
import 'package:the_app/src/constants.dart';
import 'package:the_app/src/intl.dart';

class Developer extends ChangeNotifier {
  bool _;

  bool get value => _;

  Developer._();

  set value(bool v) {
    _ = v;
    notifyListeners();

    SharedPreferences.getInstance().then((prefs) => v == null
        ? prefs.remove(kPrefKeyDeveloper)
        : prefs.setBool(kPrefKeyDeveloper, _));
  }

  static Future<Developer> create() async {
    final developer = Developer._();
    final prefs = await SharedPreferences.getInstance();
    developer._ = prefs.getBool(kPrefKeyDeveloper);
    return developer;
  }
}

class DeveloperMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Consumer<Developer>(
        builder: (_, developer, __) => developer.value == true
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
            _CrashTestWidget(),
          ],
        ),
      );
}

class PackageInfoWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PackageInfoState();
}

class _PackageInfoState extends State<PackageInfoWidget> {
  PackageInfo _info;
  var count = 0;

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) => setState(() => _info = info));
  }

  @override
  Widget build(BuildContext context) {
    final developer = context.watch<Developer>();
    return ListTile(
      title: Text(l(context).appVersion),
      subtitle: Text(_info != null
          ? l(context).appVersionInfo(_info.version, _info.buildNumber)
          : l(context).appVersionNotAvailable),
      onTap: developer.value == true
          ? null
          : () {
              if (++count > 3) {
                developer.value = true;
              }
            },
    );
  }
}

class _CrashTestWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ListTile(
        title: Text(l(context).menuDeveloperCrashTest),
        onTap: () => error_reporting.crash(),
      );
}

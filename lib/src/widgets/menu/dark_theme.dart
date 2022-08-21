import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_app/src/constants.dart';
import 'package:the_app/src/intl.dart';

class DarkTheme extends ChangeNotifier {
  bool? _value;

  bool? get value => _value;

  DarkTheme._();

  set value(bool? v) {
    _value = v;
    notifyListeners();

    SharedPreferences.getInstance().then((prefs) => v == null
        ? prefs.remove(kPrefKeyDarkTheme)
        : prefs.setBool(kPrefKeyDarkTheme, v));
  }

  static Future<DarkTheme> create() async {
    final darkTheme = DarkTheme._();
    final prefs = await SharedPreferences.getInstance();
    darkTheme._value = prefs.getBool(kPrefKeyDarkTheme);
    return darkTheme;
  }
}

class MenuDarkTheme extends StatelessWidget {
  const MenuDarkTheme({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Consumer<DarkTheme>(
        builder: (_, darkTheme, __) => ListTile(
          leading: Checkbox(
            onChanged: (_) => _updateValue(context),
            tristate: true,
            value: darkTheme.value,
          ),
          title: Text(l(context).menuDarkTheme),
          subtitle: Text(
            darkTheme.value == false
                ? l(context).menuDarkTheme0
                : darkTheme.value == true
                    ? l(context).menuDarkTheme1
                    : l(context).menuDarkThemeAuto,
          ),
          onTap: () => _updateValue(context),
        ),
      );

  void _updateValue(BuildContext context) {
    final darkTheme = context.read<DarkTheme>();
    final value = darkTheme.value;
    darkTheme.value = value == false
        ? true
        : value == true
            ? null
            : false;
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants.dart';

class DarkTheme extends ChangeNotifier {
  bool _value;

  bool get value => _value;

  set value(bool v) {
    _value = v;
    notifyListeners();

    SharedPreferences.getInstance().then((prefs) => v == null
        ? prefs.remove(kPrefKeyDarkTheme)
        : prefs.setBool(kPrefKeyDarkTheme, _value));
  }

  DarkTheme() {
    SharedPreferences.getInstance().then((prefs) {
      _value = prefs.getBool(kPrefKeyDarkTheme);
      notifyListeners();
    });
  }
}

class MenuDarkTheme extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Consumer<DarkTheme>(
        builder: (_, darkTheme, __) => ListTile(
          leading: Checkbox(
            onChanged: (_) => _updateValue(context),
            tristate: true,
            value: darkTheme.value,
          ),
          title: Text('Dark theme'),
          subtitle: Text(
            darkTheme.value == false
                ? 'No, use light theme'
                : darkTheme.value == true
                    ? 'Yes, use dark theme'
                    : "Use system's color scheme",
          ),
          onTap: () => _updateValue(context),
        ),
      );

  void _updateValue(BuildContext context) {
    final darkTheme = Provider.of<DarkTheme>(context, listen: false);
    final value = darkTheme.value;
    darkTheme.value = value == false ? true : value == true ? null : false;
  }
}

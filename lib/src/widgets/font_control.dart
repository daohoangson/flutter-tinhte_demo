import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_app/src/constants.dart';
import 'package:the_app/src/intl.dart';
import 'package:the_app/src/widgets/menu/dark_theme.dart';

abstract class FontScale extends ChangeNotifier {
  static var min = .5;
  static var max = 3.0;

  double get value;
  set value(double v);

  static Future<FontScale> create() async {
    final fontScale = _FontScale();
    final prefs = await SharedPreferences.getInstance();
    fontScale._value = prefs.getDouble(kPrefKeyFontScale);
    return fontScale;
  }
}

class _FontScale extends ChangeNotifier implements FontScale {
  double? _value;

  @override
  double get value => _value ?? 1.0;

  @override
  set value(double v) {
    if (v < FontScale.min || v > FontScale.max) return;
    _value = v;
    notifyListeners();

    SharedPreferences.getInstance()
        .then((prefs) => prefs.setDouble(kPrefKeyFontScale, v));
  }
}

class FontControlWidget extends StatelessWidget {
  const FontControlWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(FontAwesomeIcons.font),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (_) => _FontControlBottomSheet(),
          showDragHandle: true,
        );
      },
      tooltip: l(context).fontControlTooltip,
    );
  }
}

class _FontControlBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const MenuDarkTheme(),
        Padding(
          padding: const EdgeInsets.all(kPadding),
          child: Text(
            l(context).fontScaleAdjust,
            style: theme.textTheme.titleLarge,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(kPadding),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.all(kPadding),
                child: Text('a'),
              ),
              Expanded(
                child: Consumer<FontScale>(
                  builder: (context, fontScale, _) => Slider.adaptive(
                    divisions: (FontScale.max - FontScale.min) ~/ .25,
                    min: FontScale.min,
                    max: FontScale.max,
                    onChanged: (newValue) => fontScale.value = newValue,
                    value: fontScale.value,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(kPadding),
                child: Text('A'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

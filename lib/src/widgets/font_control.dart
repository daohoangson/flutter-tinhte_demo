import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tinhte_demo/src/constants.dart';

class FontScale extends ChangeNotifier {
  double _value;

  double get value => _value ?? 1.0;

  FontScale._();

  set value(double v) {
    if (v < .5 || v > 3) return;
    _value = v;
    notifyListeners();

    SharedPreferences.getInstance().then((prefs) => v == null
        ? prefs.remove(kPrefKeyFontScale)
        : prefs.setDouble(kPrefKeyFontScale, _value));
  }

  static Future<FontScale> create() async {
    final fontScale = FontScale._();
    final prefs = await SharedPreferences.getInstance();
    fontScale._value = prefs.getDouble(kPrefKeyFontScale);
    return fontScale;
  }
}

class FontControlWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _FontControlState();

  static final routeObserver = RouteObserver<PageRoute>();
}

class _FontControlState extends State<FontControlWidget> with RouteAware {
  final _key = GlobalKey();

  bool _isMenuOpen = false;
  OverlayEntry _overlayEntry;

  @override
  Widget build(BuildContext context) => IconButton(
        icon: Icon(FontAwesomeIcons.font, key: _key),
        onPressed: () => _isMenuOpen ? _menuClose() : _menuOpen(),
      );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    FontControlWidget.routeObserver.subscribe(this, ModalRoute.of(context));
  }

  @override
  void didPushNext() {
    if (_isMenuOpen) _menuClose();
  }

  @override
  void dispose() {
    if (_isMenuOpen) _menuClose();
    FontControlWidget.routeObserver.unsubscribe(this);
    super.dispose();
  }

  OverlayEntry _buildOverlayEntry() {
    RenderBox renderBox = _key.currentContext.findRenderObject();
    final buttonSize = renderBox.size;
    final buttonPosition = renderBox.localToGlobal(Offset.zero);
    final screenWidth = MediaQuery.of(context).size.width;
    final top = buttonPosition.dy + buttonSize.height;
    final right = screenWidth - (buttonPosition.dx + buttonSize.width);
    final theme = Theme.of(context);

    return OverlayEntry(
        builder: (_) => Positioned(
            top: top,
            right: right,
            child: Opacity(
              child: Material(
                borderRadius: BorderRadius.circular(8),
                color: theme.dialogBackgroundColor,
                child: Builder(builder: (context) {
                  final style = DefaultTextStyle.of(context).style;

                  return Row(
                    children: <Widget>[
                      InkWell(
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Icon(FontAwesomeIcons.minus),
                        ),
                        onTap: () => context.read<FontScale>().value -= .25,
                      ),
                      InkWell(
                        child: SizedBox(
                          child: Text(
                            '${(context.watch<FontScale>().value * 100).toInt()}%',
                            textAlign: TextAlign.center,
                          ),
                          width: style.fontSize * 3,
                        ),
                        onTap: () => context.read<FontScale>().value = 1,
                      ),
                      InkWell(
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Icon(FontAwesomeIcons.plus),
                        ),
                        onTap: () => context.read<FontScale>().value += .25,
                      ),
                    ],
                    mainAxisSize: MainAxisSize.min,
                  );
                }),
              ),
              opacity: .7,
            )));
  }

  void _menuClose() {
    _overlayEntry.remove();
    _isMenuOpen = false;
    _overlayEntry = null;
  }

  void _menuOpen() {
    _overlayEntry = _buildOverlayEntry();
    Overlay.of(context).insert(_overlayEntry);
    _isMenuOpen = true;
  }
}

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_app/src/constants.dart';

class FontScale extends ChangeNotifier {
  double? _value;

  double get value => _value ?? 1.0;

  FontScale._();

  set value(double v) {
    if (v < .5 || v > 3) return;
    _value = v;
    notifyListeners();

    SharedPreferences.getInstance()
        .then((prefs) => prefs.setDouble(kPrefKeyFontScale, v));
  }

  static Future<FontScale> create() async {
    final fontScale = FontScale._();
    final prefs = await SharedPreferences.getInstance();
    fontScale._value = prefs.getDouble(kPrefKeyFontScale);
    return fontScale;
  }
}

class FontControlWidget extends StatefulWidget {
  const FontControlWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _FontControlState();

  static final routeObserver = RouteObserver<ModalRoute<void>>();
}

class _FontControlState extends State<FontControlWidget> with RouteAware {
  final _key = GlobalKey();

  bool _isMenuOpen = false;
  OverlayEntry? _overlayEntry;

  @override
  Widget build(BuildContext context) => IconButton(
        icon: Icon(FontAwesomeIcons.font, key: _key),
        onPressed: () => _isMenuOpen ? _menuClose() : _menuOpen(),
      );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    FontControlWidget.routeObserver.subscribe(this, ModalRoute.of(context)!);
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
    final renderBox = _key.currentContext?.findRenderObject() as RenderBox;
    final buttonSize = renderBox.size;
    final buttonPosition = renderBox.localToGlobal(Offset.zero);
    final screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);

    final direction = Directionality.of(context);
    final top = buttonPosition.dy + buttonSize.height;
    final right = direction == TextDirection.ltr
        ? screenWidth - (buttonPosition.dx + buttonSize.width)
        : null;
    final left = direction == TextDirection.rtl ? buttonPosition.dx : null;

    return OverlayEntry(
        builder: (_) => Positioned(
            top: top,
            left: left,
            right: right,
            child: Opacity(
              opacity: .7,
              child: Material(
                borderRadius: BorderRadius.circular(8),
                color: theme.dialogBackgroundColor,
                child: Builder(builder: (context) {
                  final style = DefaultTextStyle.of(context).style;
                  final fontSize = style.fontSize;

                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      InkWell(
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(FontAwesomeIcons.minus),
                        ),
                        onTap: () => context.read<FontScale>().value -= .25,
                      ),
                      InkWell(
                        child: SizedBox(
                          width: fontSize != null ? fontSize * 3 : null,
                          child: Text(
                            '${(context.watch<FontScale>().value * 100).toInt()}%',
                            textAlign: TextAlign.center,
                          ),
                        ),
                        onTap: () => context.read<FontScale>().value = 1,
                      ),
                      InkWell(
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(FontAwesomeIcons.plus),
                        ),
                        onTap: () => context.read<FontScale>().value += .25,
                      ),
                    ],
                  );
                }),
              ),
            )));
  }

  void _menuClose() {
    _overlayEntry?.remove();
    _isMenuOpen = false;
    _overlayEntry = null;
  }

  void _menuOpen() {
    final overlayEntry = _overlayEntry = _buildOverlayEntry();
    Overlay.of(context).insert(overlayEntry);
    _isMenuOpen = true;
  }
}

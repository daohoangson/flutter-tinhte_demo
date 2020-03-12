import 'package:flutter/widgets.dart';

class DismissKeyboard extends StatelessWidget {
  final Widget child;

  const DismissKeyboard(this.child, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) => GestureDetector(
        child: child,
        onTap: () {
          // https://flutterigniter.com/dismiss-keyboard-form-lose-focus/
          final focus = FocusScope.of(context);
          if (!focus.hasPrimaryFocus) focus.unfocus();
        },
      );
}

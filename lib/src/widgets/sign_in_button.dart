import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SignInButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final _SignInButtonType _type;

  const SignInButton.apple({
    super.key,
    required this.onPressed,
    required this.text,
  })  : _type = _SignInButtonType.apple;

  const SignInButton.google({
    super.key,
    required this.onPressed,
    required this.text,
  })  : _type = _SignInButtonType.google;

  @override
  Widget build(BuildContext context) {
    Color? backgroundColor;
    IconData? icon;

    switch (_type) {
      case _SignInButtonType.apple:
        backgroundColor = const Color(0xFF000000);
        icon = FontAwesomeIcons.apple;
        break;
      case _SignInButtonType.google:
        backgroundColor = const Color(0xFF4285F4);
        icon = FontAwesomeIcons.google;
        break;
    }

    return MaterialButton(
      key: key,
      color: backgroundColor,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      onPressed: onPressed,
      splashColor: Colors.white30,
      highlightColor: Colors.white30,
      child: Center(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: DefaultTextStyle.of(context).style.fontSize,
              color: Colors.white,
            ),
            SizedBox(width: ButtonTheme.of(context).padding.horizontal / 2),
            Text(
              text,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

enum _SignInButtonType {
  apple,
  google,
}

import 'package:flutter/material.dart';

class HeaderWidget extends StatelessWidget {
  final String text;

  HeaderWidget(this.text, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(5.0, 20.0, 5.0, 10.0),
        child: Text(
          text.toUpperCase(),
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
}

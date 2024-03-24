import 'package:flutter/material.dart';

class HeaderWidget extends StatelessWidget {
  final String text;

  const HeaderWidget(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(10.0),
        child: Text(
          text,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      );
}

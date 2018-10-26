import 'package:flutter/material.dart';

Widget buildProgressIndicator(bool visible) => Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Opacity(
          opacity: visible ? 1.0 : 0.0,
          child: const CircularProgressIndicator(),
        ),
      ),
    );

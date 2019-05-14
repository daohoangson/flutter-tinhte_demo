import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

import 'src/api.dart';
import 'src/responsive_layout.dart';

void main() {
  FlutterError.onError = (e) => Crashlytics.instance.onError(e);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ApiApp(
        MaterialApp(
          title: 'Tinh tế Demo',
          theme: ThemeData(
            accentColor: const Color(0xFF00BAD7),
            primaryColor: const Color(0xFF192533),
            brightness: Brightness.light,
          ),
          home: SafeArea(child: ResponsiveLayout()),
        ),
      );
}

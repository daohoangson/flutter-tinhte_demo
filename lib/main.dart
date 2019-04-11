import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'src/api.dart';
import 'src/push_notification.dart';
import 'src/responsive_layout.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ApiApp(
        PushNotificationApp(
          MaterialApp(
            title: 'Tinh tế Demo',
            theme: ThemeData(
              accentColor: const Color(0xFF00BAD7),
              primaryColor: const Color(0xFF192533),
              brightness: Brightness.light,
            ),
            home: SafeArea(child: ResponsiveLayout()),
          ),
        ),
      );
}

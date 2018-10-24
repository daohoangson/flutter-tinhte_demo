import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'src/screens/home.dart';
import 'src/api.dart';

// https://medium.com/@kr1uz/how-to-restrict-device-orientation-in-flutter-65431cd35113
void main() =>
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
        .then((_) => runApp(MyApp()));

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) => ApiApp(
      apiRoot: 'https://tinhte.vn/appforo/index.php',
      clientId: '',
      clientSecret: '',
      child: MaterialApp(
        title: 'Tinh tế Demo',
        theme: ThemeData(
          accentColor: const Color(0xFF00BAD7),
          primaryColor: const Color(0xFF192533),
          brightness: Brightness.light,
        ),
        home: SafeArea(child: HomeScreen()),
      ));
}

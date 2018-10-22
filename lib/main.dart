import 'package:flutter/material.dart';

import 'src/screens/home.dart';
import 'src/api.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) => ApiInheritedWidget(
      apiRoot: 'https://tinhte.vn/appforo/index.php',
      clientId: '',
      clientSecret: '',
      child: MaterialApp(
        title: 'Tinh tế Demo',
        theme: ThemeData(
          brightness: Brightness.dark,
        ),
        home: SafeArea(child: HomeScreen()),
      ));
}

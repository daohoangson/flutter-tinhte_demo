import 'package:flutter/material.dart';

import 'package:tinhte_demo/api/api.dart';
import 'src/screens/home.dart';
import 'src/widgets/api.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new ApiInheritedWidget(
      api: new Api('https://tinhte.vn/appforo/index.php', '', ''),
      child: new MaterialApp(
        title: 'Tinh tế Demo',
        theme: new ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: new HomeScreen(title: 'Tinh tế Home (demo)'),
      )
    );
  }
}



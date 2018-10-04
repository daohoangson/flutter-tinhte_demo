import 'package:flutter/material.dart';

import 'package:tinhte_demo/api/api.dart';
import 'src/screens/home.dart';
import 'src/widgets/api.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final api = Api('https://tinhte.vn/appforo/index.php', '', '');
    api.httpHeaders['Api-Bb-Code-Chr'] = '1';

    return ApiInheritedWidget(
      api: api,
      child: MaterialApp(
        title: 'Tinh tế Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: HomeScreen(title: 'Tinh tế Home (demo)'),
      )
    );
  }
}



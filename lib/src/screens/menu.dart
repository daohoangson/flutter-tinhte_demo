import 'package:flutter/material.dart';

import '../widgets/app_bar.dart';

class MenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Menu'),
        ),
        body: ListView(
          children: <Widget>[
            AppBarDrawerHeader(),
            AppBarDrawerFooter(),
          ],
        ),
      );
}

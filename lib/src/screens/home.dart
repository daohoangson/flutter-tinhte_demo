import 'package:flutter/material.dart';

import '../widgets/navigation.dart';
import '../widgets/threads.dart';

class HomeScreen extends StatelessWidget {
  final String title;

  HomeScreen({Key key, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: ThreadsWidget(path: 'lists/1/threads'),
        drawer: Drawer(
          child: NavigationWidget(path: 'navigation?parent=0'),
        ),
      );
}

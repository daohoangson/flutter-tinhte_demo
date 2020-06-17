import 'package:flutter/material.dart';
import 'package:tinhte_demo/src/intl.dart';
import 'package:tinhte_demo/src/widgets/navigation.dart';

class ForumListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(l(context).forums),
        ),
        body: NavigationWidget(path: 'navigation?parent=0'),
      );
}

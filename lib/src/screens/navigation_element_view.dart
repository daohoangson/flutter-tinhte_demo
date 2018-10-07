import 'package:flutter/material.dart';

import 'package:tinhte_demo/api/model/navigation.dart' as navigation;

import '../widgets/navigation.dart';

class NavigationElementViewScreen extends StatelessWidget {
  final navigation.Element element;

  NavigationElementViewScreen({this.element, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(element.node.title),
        ),
        body: NavigationWidget(path: element.links.subElements),
      );
}

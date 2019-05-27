import 'package:flutter/material.dart';
import 'package:tinhte_api/navigation.dart' as navigation;

import '../widgets/navigation.dart';

class NodeViewScreen extends StatelessWidget {
  final navigation.Element element;

  NodeViewScreen(this.element, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(element.node.title),
        ),
        body: NavigationWidget(path: element.links.subElements),
      );
}

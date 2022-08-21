import 'package:flutter/material.dart';
import 'package:the_api/node.dart';
import 'package:the_app/src/widgets/navigation.dart';

class NodeViewScreen extends StatelessWidget {
  final Node node;

  const NodeViewScreen(this.node, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(node.title ?? ''),
        ),
        body: NavigationWidget(
          path: node.links?.subElements ?? '',
        ),
      );
}

import 'package:flutter/material.dart';
import 'package:the_api/node.dart';
import 'package:the_app/src/widgets/navigation.dart';

class NodeViewScreen extends StatelessWidget {
  final Node node;

  NodeViewScreen(this.node, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(node.map(
            (value) => '#${value.navigationId}',
            category: (category) => category.categoryTitle,
            forum: (forum) => forum.forumTitle,
            linkforum: (link) => link.linkTitle,
          )),
        ),
        body: NavigationWidget(
          path: node.map(
            (_) => _.links.subElements,
            category: (_) => _.links.subElements,
            forum: (_) => _.links.subElements,
            linkforum: (_) => _.links.subElements,
          ),
        ),
      );
}

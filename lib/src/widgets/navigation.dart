import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tinhte_api/navigation.dart' as navigation;

import '../screens/forum_view.dart';
import '../screens/navigation_element_view.dart';
import '../api.dart';
import '_list_view.dart';

class NavigationWidget extends StatefulWidget {
  final Widget footer;
  final Widget header;
  final String path;

  NavigationWidget({
    this.footer,
    this.header,
    Key key,
    @required this.path,
  }) : super(key: key);

  @override
  _NavigationWidgetState createState() => _NavigationWidgetState();
}

class _NavigationWidgetState extends State<NavigationWidget> {
  final List<navigation.Element> elements = List();
  bool hasFetched = false;

  _NavigationWidgetState();

  @override
  Widget build(BuildContext context) {
    if (!hasFetched) fetch();

    return ListView.builder(
      itemBuilder: (context, i) {
        if (widget.header != null) {
          if (i == 0) return widget.header;
          i--;
        }

        if (widget.footer != null) {
          if (i == elements.length) return widget.footer;
        }

        if (i >= elements.length) return buildProgressIndicator(!hasFetched);
        return _buildRow(elements[i]);
      },
      itemCount: (widget.header != null ? 1 : 0) +
          elements.length +
          1 +
          (widget.footer != null ? 1 : 0),
    );
  }

  void fetch() async {
    if (hasFetched) return;
    setState(() => hasFetched = true);

    apiGet(this, widget.path, onSuccess: (jsonMap) {
      List<navigation.Element> newElements = List();

      if (jsonMap.containsKey('elements')) {
        final list = jsonMap['elements'] as List;
        list.forEach((j) => newElements.add(navigation.Element.fromJson(j)));
      }

      setState(() => elements.addAll(newElements));
    });
  }

  Widget _buildRow(navigation.Element e) => ListTile(
        title: Text(e.node?.title ?? "#${e.navigationId}"),
        onTap: () {
          switch (e.navigationType) {
            case navigation.NavigationTypeCategory:
              if (e.hasSubElements) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            NavigationElementViewScreen(element: e)));
              }
              break;
            case navigation.NavigationTypeForum:
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ForumViewScreen(forum: e.node)));
              break;
            case navigation.NavigationTypeLinkForum:
              final linkForum = e.node as navigation.LinkForum;
              final url = linkForum.links.target;
              canLaunch(url).then((ok) => ok ? launch(url) : null);
              break;
          }
        },
      );
}

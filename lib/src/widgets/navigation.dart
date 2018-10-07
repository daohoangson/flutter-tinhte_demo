import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:tinhte_demo/api/model/navigation.dart' as navigation;

import '../screens/forum_view.dart';
import '../screens/navigation_element_view.dart';
import 'api.dart';

class NavigationWidget extends StatefulWidget {
  final String path;

  NavigationWidget({Key key, @required this.path}) : super(key: key);

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
        if (i >= elements.length) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return _buildRow(elements[i]);
      },
      itemCount: elements.isEmpty ? 1 : elements.length,
    );
  }

  void fetch() async {
    if (hasFetched) {
      return;
    }
    setState(() => hasFetched = true);

    List<navigation.Element> newElements = List();

    final api = ApiInheritedWidget.of(context).api;
    final json = await api.getJson(widget.path);
    final jsonMap = json as Map<String, dynamic>;
    if (jsonMap.containsKey('elements')) {
      final jsonElements = json['elements'] as List<dynamic>;
      jsonElements
          .forEach((j) => newElements.add(navigation.Element.fromJson(j)));
    }

    setState(() => elements.addAll(newElements));
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

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tinhte_api/navigation.dart' as navigation;
import 'package:the_app/src/screens/forum_view.dart';
import 'package:the_app/src/screens/node_view.dart';
import 'package:the_app/src/widgets/super_list.dart';

class NavigationWidget extends StatelessWidget {
  final Widget footer;
  final Widget header;
  final List<navigation.Element> initialElements;
  final String path;
  final bool progressIndicator;
  final bool shrinkWrap;

  NavigationWidget({
    this.footer,
    this.header,
    this.initialElements = const [],
    Key key,
    @required this.path,
    this.progressIndicator,
    this.shrinkWrap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => SuperListView<navigation.Element>(
        fetchOnSuccess: _fetchOnSuccess,
        fetchPathInitial: path,
        footer: footer,
        header: header,
        initialItems: initialElements,
        itemBuilder: (context, __, element) => _buildRow(context, element),
        progressIndicator: progressIndicator,
        shrinkWrap: shrinkWrap,
      );

  Widget _buildRow(BuildContext context, navigation.Element e) => ListTile(
        title: Text(e.node?.title ?? "#${e.navigationId}"),
        onTap: () {
          switch (e.navigationType) {
            case navigation.NavigationTypeCategory:
              if (e.hasSubElements) {
                Navigator.push(
                  context,
                  NavigationRoute((_) => NodeViewScreen(e)),
                );
              }
              break;
            case navigation.NavigationTypeForum:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ForumViewScreen(e.node)),
              );
              break;
            case navigation.NavigationTypeLinkForum:
              final linkForum = e.node as navigation.LinkForum;
              final url = linkForum.links.target;
              canLaunch(url).then((ok) => ok ? launch(url) : null);
              break;
            default:
              Navigator.pushNamed(context, e.navigationType);
          }
        },
      );

  void _fetchOnSuccess(Map json, FetchContext<navigation.Element> fc) {
    if (!json.containsKey('elements')) return;

    final list = json['elements'] as List;
    fc.items.addAll(list.map((j) => navigation.Element.fromJson(j)));
  }
}

class NavigationRoute extends MaterialPageRoute {
  NavigationRoute(WidgetBuilder builder) : super(builder: builder);
}

import 'package:flutter/material.dart';
import 'package:the_api/node.dart';
import 'package:the_app/src/link.dart';
import 'package:the_app/src/screens/forum_view.dart';
import 'package:the_app/src/screens/node_view.dart';
import 'package:the_app/src/widgets/super_list.dart';

class NavigationWidget extends StatelessWidget {
  final Widget? footer;
  final Widget? header;
  final List<Node> initialElements;
  final String path;
  final bool? progressIndicator;
  final bool? shrinkWrap;

  const NavigationWidget({
    this.footer,
    this.header,
    this.initialElements = const [],
    Key? key,
    required this.path,
    this.progressIndicator,
    this.shrinkWrap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => SuperListView<Node>(
        fetchOnSuccess: _fetchOnSuccess,
        fetchPathInitial: path,
        footer: footer,
        header: header,
        initialItems: initialElements,
        itemBuilder: (context, __, element) => _buildRow(context, element),
        progressIndicator: progressIndicator,
        shrinkWrap: shrinkWrap,
      );

  Widget _buildRow(BuildContext context, Node node) => node.map(
        (node) => ListTile(
          title: Text("#${node.navigationId}"),
        ),
        category: (category) => ListTile(
          title: Text(category.categoryTitle ?? '#${category.categoryId}'),
          onTap: () => Navigator.push(
              context, NavigationRoute((_) => NodeViewScreen(category))),
        ),
        forum: (forum) => ListTile(
          title: Text(forum.forumTitle ?? '#${forum.forumId}'),
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => ForumViewScreen(forum))),
        ),
        linkforum: (link) {
          final target = link.links?.target;
          return ListTile(
            title: Text(link.linkTitle ?? '#${link.linkId}'),
            onTap: target != null ? () => launchLink(context, target) : null,
          );
        },
      );

  void _fetchOnSuccess(Map json, FetchContext<Node> fc) {
    if (!json.containsKey('elements')) return;

    final list = json['elements'] as List;
    fc.items.addAll(list.map((j) => Node.fromJson(j)));
  }
}

class NavigationRoute extends MaterialPageRoute {
  NavigationRoute(WidgetBuilder builder) : super(builder: builder);
}

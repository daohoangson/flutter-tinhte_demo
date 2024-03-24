part of '../threads.dart';

const _kThreadNavigationFontSize = 12.0;
const _kThreadNavigationMargin = 10.0;
const _kThreadNavigationSeparatorPadding = 2.0;

class ThreadNavigationWidget extends StatefulWidget {
  final Thread thread;

  const ThreadNavigationWidget(this.thread, {super.key});

  @override
  State<ThreadNavigationWidget> createState() => _ThreadNavigationState();
}

class _ThreadNavigationState extends State<ThreadNavigationWidget> {
  List<Node> get nodes {
    final navigation = widget.thread.navigation;
    if (navigation != null) return navigation;

    final node = widget.thread.node;
    return [if (node != null) node];
  }

  @override
  void initState() {
    super.initState();
    if (widget.thread.navigation == null) {
      _fetch();
    }
  }

  @override
  Widget build(BuildContext context) => SizedBox(
        height: _kThreadNavigationMargin * 2 + _kThreadNavigationFontSize * 1.5,
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: _kThreadNavigationMargin),
          child: ListView.separated(
            itemBuilder: (context, i) => i < nodes.length
                ? _buildNode(context, nodes[i])
                : _buildText(context, ''),
            itemCount: nodes.isEmpty ? 1 : nodes.length,
            scrollDirection: Axis.horizontal,
            separatorBuilder: (context, _) => _buildSeparator(context),
          ),
        ),
      );

  Widget _buildSeparator(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: _kThreadNavigationSeparatorPadding),
        child: Icon(
          FontAwesomeIcons.caretRight,
          size: _kThreadNavigationFontSize,
          color: Theme.of(context).textTheme.bodySmall?.color,
        ),
      );

  Widget _buildNode(BuildContext context, Node node) => node.map(
        (node) => _buildText(context, '#${node.navigationId}'),
        category: (category) => InkWell(
          child: _buildText(
              context, category.categoryTitle ?? '#${category.categoryId}'),
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => NodeViewScreen(category))),
        ),
        forum: (forum) => InkWell(
          child: _buildText(context, forum.forumTitle ?? '#${forum.forumId}'),
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => ForumViewScreen(forum))),
        ),
        linkforum: (link) {
          final target = link.links?.target;
          return InkWell(
            onTap: target != null ? () => launchLink(context, target) : null,
            child: _buildText(context, link.linkTitle ?? '#${link.linkId}'),
          );
        },
      );

  Widget _buildText(BuildContext context, String data) => Padding(
      padding: const EdgeInsets.symmetric(vertical: _kThreadNavigationMargin),
      child: Center(
        child: Text(
          data,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                height: 1,
                fontSize: _kThreadNavigationFontSize,
              ),
          textAlign: TextAlign.center,
        ),
      ));

  void _fetch() => apiGet(
        ApiCaller.stateful(this),
        "threads/${widget.thread.threadId}/navigation",
        onSuccess: (jsonMap) {
          if (!jsonMap.containsKey('elements')) return;
          final list = jsonMap['elements'] as List;
          final nodes = list
              .map((nodeJson) => Node.fromJson(nodeJson))
              .toList(growable: false);
          if (nodes.isNotEmpty) {
            widget.thread.navigation = nodes;
          }
        },
      );
}

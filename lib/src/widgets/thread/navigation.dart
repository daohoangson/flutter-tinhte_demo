part of '../threads.dart';

const _kThreadNavigationFontSize = 12.0;
const _kThreadNavigationMargin = 10.0;
const _kThreadNavigationSeparatorPadding = 2.0;

class ThreadNavigationWidget extends StatefulWidget {
  final Thread thread;

  ThreadNavigationWidget(this.thread) : assert(thread != null);

  @override
  State<ThreadNavigationWidget> createState() => _ThreadNavigationState();
}

class _ThreadNavigationState extends State<ThreadNavigationWidget> {
  List<Node> get nodes =>
      widget.thread.navigation ??
      [if (widget.thread.node != null) widget.thread.node];

  @override
  void initState() {
    super.initState();
    if (widget.thread.navigation == null) {
      _fetch();
    }
  }

  @override
  Widget build(BuildContext _) => SizedBox(
        child: Padding(
          child: ListView.separated(
            itemBuilder: (context, i) => i < nodes.length
                ? _buildNode(context, nodes[i])
                : _buildText(context, ''),
            itemCount: nodes.isEmpty ? 1 : nodes.length,
            scrollDirection: Axis.horizontal,
            separatorBuilder: (context, _) => _buildSeparator(context),
          ),
          padding:
              const EdgeInsets.symmetric(horizontal: _kThreadNavigationMargin),
        ),
        height: _kThreadNavigationMargin * 2 + _kThreadNavigationFontSize * 1.5,
      );

  Widget _buildSeparator(BuildContext context) => Padding(
        child: Icon(
          FontAwesomeIcons.caretRight,
          size: _kThreadNavigationFontSize,
          color: Theme.of(context).textTheme.caption.color,
        ),
        padding: const EdgeInsets.symmetric(
            horizontal: _kThreadNavigationSeparatorPadding),
      );

  Widget _buildNode(BuildContext context, Node node) => node.map(
        (node) => _buildText(context, '#${node.navigationId}'),
        category: (category) => InkWell(
          child: _buildText(context, category.categoryTitle),
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => NodeViewScreen(category))),
        ),
        forum: (forum) => InkWell(
          child: _buildText(context, forum.forumTitle),
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => ForumViewScreen(forum))),
        ),
        linkforum: (link) => InkWell(
          child: _buildText(context, link.linkTitle),
          onTap: () => launchLink(context, link.links.target),
        ),
      );

  Widget _buildText(BuildContext context, String data) => Padding(
      child: Center(
        child: Text(
          data,
          style: Theme.of(context).textTheme.caption.copyWith(
                height: 1,
                fontSize: _kThreadNavigationFontSize,
              ),
          textAlign: TextAlign.center,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: _kThreadNavigationMargin));

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

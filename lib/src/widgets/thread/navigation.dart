part of '../threads.dart';

const _kThreadNavigationFontSize = 12.0;
const _kThreadNavigationMargin = 10.0;
const _kThreadNavigationSeparatorPadding = 2.0;

class ThreadNavigationWidget extends StatelessWidget {
  final Thread thread;

  ThreadNavigationWidget(this.thread) : assert(thread != null);

  void _initData(BuildContext context, _ThreadNavigationData data) {
    data.nodes = [];

    final forum = thread.forum;
    if (forum != null) {
      data.nodes.add(forum);
    }

    _fetch(context, data);
  }

  @override
  Widget build(BuildContext _) =>
      Consumer<_ThreadNavigationData>(builder: (context, data, _) {
        if (data.nodes == null) _initData(context, data);
        return _buildBox(data.nodes);
      });

  Widget _buildBox(List<Node> nodes) => SizedBox(
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

  void _fetch(BuildContext context, _ThreadNavigationData data) => apiGet(
        ApiCaller.stateless(context),
        "threads/${thread.threadId}/navigation",
        onSuccess: (jsonMap) {
          if (!jsonMap.containsKey('elements')) return;
          final list = jsonMap['elements'] as List;
          final elements = list.map((map) => Node.fromJson(map));
          if (elements.isNotEmpty) data.update(elements);
        },
      );

  static InheritedProvider buildProvider() =>
      ChangeNotifierProvider<_ThreadNavigationData>(
          create: (_) => _ThreadNavigationData());
}

class _ThreadNavigationData extends ChangeNotifier {
  List<Node> nodes;

  void update(Iterable<Node> newNodes) {
    nodes.clear();
    nodes.addAll(newNodes);
    notifyListeners();
  }
}

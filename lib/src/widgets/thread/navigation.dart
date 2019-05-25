part of '../threads.dart';

const _kThreadNavigationFontSize = 12.0;
const _kThreadNavigationMargin = 10.0;
const _kThreadNavigationSeparatorPadding = 2.0;

class ThreadNavigation extends StatefulWidget {
  final Thread thread;

  ThreadNavigation(this.thread) : assert(thread != null);

  @override
  State<StatefulWidget> createState() => _ThreadNavigationState();
}

class _ThreadNavigationState extends State<ThreadNavigation> {
  final elements = <navigation.Element>[];

  @override
  void initState() {
    super.initState();

    if (widget.thread.forum != null) {
      final forum = widget.thread.forum;
      elements.add(navigation.Element(
        forum.forumId,
        navigation.NavigationTypeForum,
      )..node = forum);
    }

    _fetch();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
        child: Padding(
          child: ListView.separated(
            itemBuilder: (context, i) => i < elements.length
                ? _buildElement(context, elements[i])
                : _buildText(context, ''),
            itemCount: elements.isEmpty ? 1 : elements.length,
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

  Widget _buildElement(BuildContext context, navigation.Element e) => InkWell(
        child: _buildText(context, e.node.title),
        onTap: () {
          if (e.node is Forum) {
            return Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ForumViewScreen(e.node),
              ),
            );
          }

          if (e.links?.subElements?.isNotEmpty == true) {
            return Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => NodeViewScreen(e)),
            );
          }

          if (e.links?.permalink?.isNotEmpty == true) {
            launchLink(context, e.links.permalink);
          }
        },
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

          final newElements = <navigation.Element>[];
          final list = jsonMap['elements'] as List;
          for (final Map map in list) {
            final element = navigation.Element.fromJson(map);
            newElements.add(element);
          }

          if (newElements.isNotEmpty) {
            setState(() {
              elements.clear();
              elements.addAll(newElements);
            });
          }
        },
      );
}

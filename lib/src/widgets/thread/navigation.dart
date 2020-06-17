part of '../threads.dart';

const _kThreadNavigationFontSize = 12.0;
const _kThreadNavigationMargin = 10.0;
const _kThreadNavigationSeparatorPadding = 2.0;

class ThreadNavigationWidget extends StatelessWidget {
  final Thread thread;

  ThreadNavigationWidget(this.thread) : assert(thread != null);

  void _initData(BuildContext context, _ThreadNavigationData data) {
    data.elements = [];
    if (thread.forum != null) {
      final forum = thread.forum;
      data.elements.add(navigation.Element(
        forum.forumId,
        navigation.NavigationTypeForum,
      )..node = forum);
    }
    _fetch(context, data);
  }

  @override
  Widget build(BuildContext _) =>
      Consumer<_ThreadNavigationData>(builder: (context, data, _) {
        if (data.elements == null) _initData(context, data);
        return _buildBox(data.elements);
      });

  Widget _buildBox(List<navigation.Element> elements) => SizedBox(
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ForumViewScreen(e.node),
              ),
            );
            return;
          }

          if (e.links?.subElements?.isNotEmpty == true) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => NodeViewScreen(e)),
            );
            return;
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

  void _fetch(BuildContext context, _ThreadNavigationData data) => apiGet(
        ApiCaller.stateless(context),
        "threads/${thread.threadId}/navigation",
        onSuccess: (jsonMap) {
          if (!jsonMap.containsKey('elements')) return;
          final list = jsonMap['elements'] as List;
          final elements = list.map((map) => navigation.Element.fromJson(map));
          if (elements.isNotEmpty) data.update(elements);
        },
      );

  static InheritedProvider buildProvider() =>
      ChangeNotifierProvider<_ThreadNavigationData>(
          create: (_) => _ThreadNavigationData());
}

class _ThreadNavigationData extends ChangeNotifier {
  List<navigation.Element> elements;

  void update(Iterable<navigation.Element> newElements) {
    elements.clear();
    elements.addAll(newElements);
    notifyListeners();
  }
}

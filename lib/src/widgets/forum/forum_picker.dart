import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:the_api/node.dart';
import 'package:the_app/src/intl.dart';
import 'package:the_app/src/widgets/super_list.dart';

class ForumPickerWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final data = context.watch<ForumPickerData>();

    return ListTile(
      leading: Icon(FontAwesomeIcons.globe),
      title: data.forum != null
          ? Text(data.forum.forumTitle)
          : Text(l(context).threadCreateChooseAForum),
      trailing: Icon(FontAwesomeIcons.caretDown),
      onTap: () async => data.forum = await showModalBottomSheet<Forum>(
        builder: (context) => _ForumPickerBody(),
        context: context,
      ),
    );
  }
}

class _ForumPickerBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scrollbar(
        child: SuperListView<Node>(
          fetchOnSuccess: _fetchOnSuccess,
          fetchPathInitial: 'navigation',
          itemBuilder: (context, __, element) => _buildRow(context, element),
        ),
      );

  Widget _buildRow(BuildContext context, Node node) {
    Widget built = ListTile(
      title: Text(
        node.maybeMap(
          (node) => '#${node.navigationId}',
          category: (_) => _.categoryTitle,
          forum: (_) => _.forumTitle,
        ),
        style: node.maybeMap(
          (node) => null,
          forum: (_) => TextStyle(color: Theme.of(context).disabledColor),
        ),
      ),
      subtitle: node.maybeMap(
        (node) => null,
        category: (_) => _buildSubtitle(_.categoryDescription),
        forum: (_) => _buildSubtitle(_.forumDescription),
      ),
      onTap: node.maybeMap(
        (node) => null,
        forum: (_) => () => Navigator.pop(context, _),
      ),
    );

    final depth = node.navigationDepth ?? 1;
    if (depth > 1) {
      built = Padding(
        child: built,
        padding: EdgeInsets.only(left: depth * 10.0),
      );
    }

    return built;
  }

  Widget _buildSubtitle(String description) => Text(
        description,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );

  void _fetchOnSuccess(Map json, FetchContext<Node> fc) {
    if (!json.containsKey('elements')) return;

    final list = json['elements'] as List;
    fc.items.addAll(list.map((j) => Node.fromJson(j)));
  }
}

class ForumPickerData extends ChangeNotifier {
  Forum _forum;

  ForumPickerData(this._forum);

  Forum get forum => _forum;

  set forum(Forum v) {
    _forum = v;
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tinhte_api/navigation.dart' as navigation;
import 'package:tinhte_api/node.dart' as node;
import 'package:the_app/src/intl.dart';
import 'package:the_app/src/widgets/super_list.dart';

class ForumPickerWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final data = context.watch<ForumPickerData>();

    return ListTile(
      leading: Icon(FontAwesomeIcons.globe),
      title: data.forum != null
          ? Text(data.forum.title)
          : Text(l(context).threadCreateChooseAForum),
      trailing: Icon(FontAwesomeIcons.caretDown),
      onTap: () async => data.forum = await showModalBottomSheet<node.Forum>(
        builder: (context) => _ForumPickerBody(),
        context: context,
      ),
    );
  }
}

class _ForumPickerBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scrollbar(
        child: SuperListView<navigation.Element>(
          fetchOnSuccess: _fetchOnSuccess,
          fetchPathInitial: 'navigation',
          itemBuilder: (context, __, element) => _buildRow(context, element),
        ),
      );

  Widget _buildRow(BuildContext context, navigation.Element e) {
    final node.Category category = e.node is node.Category ? e.node : null;
    final node.Forum forum = e.node is node.Forum ? e.node : null;

    Widget built = ListTile(
      title: Text(
        e.node?.title ?? '#${e.navigationId}',
        style: forum != null
            ? null
            : TextStyle(color: Theme.of(context).disabledColor),
      ),
      subtitle: category != null
          ? _buildSubtitle(category.categoryDescription)
          : forum != null ? _buildSubtitle(forum.forumDescription) : null,
      onTap: forum != null ? () => Navigator.pop(context, forum) : null,
    );

    final depth = e.navigationDepth ?? 1;
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

  void _fetchOnSuccess(Map json, FetchContext<navigation.Element> fc) {
    if (!json.containsKey('elements')) return;

    final list = json['elements'] as List;
    fc.items.addAll(list.map((j) => navigation.Element.fromJson(j)));
  }
}

class ForumPickerData extends ChangeNotifier {
  node.Forum _forum;

  ForumPickerData(this._forum);

  node.Forum get forum => _forum;

  set forum(node.Forum v) {
    _forum = v;
    notifyListeners();
  }
}

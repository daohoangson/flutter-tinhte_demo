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
    final forum = data.forum;

    return ListTile(
      leading: Icon(FontAwesomeIcons.globe),
      title: forum != null
          ? Text(forum.title ?? '#${forum.forumId}')
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
    final description = node.description;
    final forum = node is Forum ? node : null;
    final canCreateThread = forum?.permissions?.createThread == true;

    Widget built = ListTile(
      title: Text(
        node.title ?? '#${node.navigationId}',
        style: canCreateThread
            ? null
            : TextStyle(color: Theme.of(context).disabledColor),
      ),
      subtitle: description != null ? _buildSubtitle(description) : null,
      onTap: canCreateThread ? () => Navigator.pop(context, forum) : null,
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

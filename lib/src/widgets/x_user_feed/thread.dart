import 'package:flutter/material.dart';
import 'package:the_api/thread.dart';
import 'package:the_api/x_user_feed.dart';
import 'package:the_app/src/link.dart';

final _sourceRegExp = RegExp(r'^(.+) (.+)$');

PopupMenuButton buildPopupMenuButtonForThread(
  BuildContext context,
  Thread thread,
  UserFeedData data,
) {
  if (data == null) return null;

  final entries = <PopupMenuEntry<String>>[];
  data.sources?.keys?.forEach((key) {
    final m = _sourceRegExp.firstMatch(key);
    if (m == null) return;
    final type = m.group(1);
    final id = m.group(2);

    switch (type) {
      case 'tag_watch':
        if (thread.threadTags?.containsKey(id) == true) {
          entries.add(PopupMenuItem(
            child: Text("#${thread.threadTags[id]}"),
            value: "tags/$id",
          ));
        }
        break;
      case 'user_follow':
        if (thread.creatorUserId.toString() == id) {
          entries.add(PopupMenuItem(
            child: Text(thread.creatorUsername),
            value: "users/$id",
          ));
        }
        break;
    }
  });

  if (entries.isEmpty) return null;

  return PopupMenuButton<String>(
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Icon(
        Icons.info,
        color: Theme.of(context).disabledColor,
      ),
    ),
    itemBuilder: (_) => entries,
    onSelected: (path) => parsePath(path, context: context),
  );
}

import 'package:json_annotation/json_annotation.dart';

import 'thread.dart';

part 'content_list.g.dart';

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class ListItem {
  final int itemId;
  String itemTitle;
  int itemDate;
  int userId;

  ListItem(this.itemId);
  factory ListItem.fromJson(Map<String, dynamic> json) =>
      _$ListItemFromJson(json);
}

class ThreadListItem {
  final ListItem item;
  final Thread thread;

  ThreadListItem(this.item, this.thread);
  factory ThreadListItem.fromJson(Map<String, dynamic> json) => ThreadListItem(
        ListItem.fromJson(json['list_item']),
        Thread.fromJson(json),
      );
}

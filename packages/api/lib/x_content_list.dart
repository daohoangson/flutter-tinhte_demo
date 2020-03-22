import 'package:json_annotation/json_annotation.dart';

part 'x_content_list.g.dart';

@JsonSerializable()
class ContentListItem {
  final int itemId;
  String itemTitle;
  int itemDate;
  int userId;

  ContentListItem(this.itemId);
  factory ContentListItem.fromJson(Map<String, dynamic> json) =>
      _$ContentListItemFromJson(json);
}

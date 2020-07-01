// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'x_content_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContentListItem _$ContentListItemFromJson(Map<String, dynamic> json) {
  return ContentListItem(
    json['item_id'] as int,
  )
    ..itemTitle = json['item_title'] as String
    ..itemDate = json['item_date'] as int
    ..userId = json['user_id'] as int;
}

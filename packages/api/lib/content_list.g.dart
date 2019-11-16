// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListItem _$ListItemFromJson(Map<String, dynamic> json) {
  return ListItem(json['item_id'] as int)
    ..itemTitle = json['item_title'] as String
    ..itemDate = json['item_date'] as int
    ..userId = json['user_id'] as int;
}

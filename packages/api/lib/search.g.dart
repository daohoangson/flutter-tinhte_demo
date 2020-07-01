// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchResult<T> _$SearchResultFromJson<T>(Map<String, dynamic> json) {
  return SearchResult<T>(
    json['content_type'] as String,
    json['content_id'] as int,
  )
    ..feedData = json['feed_data'] == null
        ? null
        : UserFeedData.fromJson(json['feed_data'] as Map<String, dynamic>)
    ..listItem = json['list_item'] == null
        ? null
        : ContentListItem.fromJson(json['list_item'] as Map<String, dynamic>);
}

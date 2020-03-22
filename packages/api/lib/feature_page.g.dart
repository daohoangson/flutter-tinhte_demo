// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feature_page.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FeaturePage _$FeaturePageFromJson(Map<String, dynamic> json) {
  return FeaturePage(
    json['forumId'] as int,
    json['fullName'] as String,
    json['is_followed'] as bool,
    json['tagId'] as int,
    json['tagText'] as String,
  )
    ..links = json['links'] == null
        ? null
        : FeaturePageLinks.fromJson(json['links'] as Map<String, dynamic>)
    ..values = json['values'] == null
        ? null
        : FeaturePageValues.fromJson(json['values'] as Map<String, dynamic>);
}

FeaturePageLinks _$FeaturePageLinksFromJson(Map<String, dynamic> json) {
  return FeaturePageLinks()
    ..follow = json['follow'] as String
    ..image = json['image'] as String
    ..permalink = json['permalink'] as String
    ..thumbnail = json['thumbnail'] as String;
}

FeaturePageValues _$FeaturePageValuesFromJson(Map<String, dynamic> json) {
  return FeaturePageValues()
    ..followerCount = json['follower_count'] as int
    ..newsCount = json['news_count'] as int
    ..tagUseCount = json['tag_use_count'] as int
    ..xDaysThreadCount = json['7_days_thread_count'] as int
    ..xDaysNewsCount = json['7_days_news_count'] as int;
}

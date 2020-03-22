// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'x_user_feed.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserFeedData _$UserFeedDataFromJson(Map<String, dynamic> json) {
  return UserFeedData()
    ..feedTime = json['feed_time'] as int
    ..score = (json['score'] as num)?.toDouble()
    ..scoreWeighted = (json['_score_weighted'] as num)?.toDouble()
    ..sortBucket = json['_sort_bucket'] as String
    ..sources = (json['_sources'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k, e as int),
    );
}

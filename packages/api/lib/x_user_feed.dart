import 'package:json_annotation/json_annotation.dart';

part 'x_user_feed.g.dart';

@JsonSerializable()
class UserFeedData {
  int feedTime;
  double score;

  @JsonKey(name: "_score_weighted")
  double scoreWeighted;

  @JsonKey(name: "_sort_bucket")
  String sortBucket;

  @JsonKey(name: "_sources")
  Map<String, int> sources;

  UserFeedData();
  factory UserFeedData.fromJson(Map<String, dynamic> json) =>
      _$UserFeedDataFromJson(json);
}

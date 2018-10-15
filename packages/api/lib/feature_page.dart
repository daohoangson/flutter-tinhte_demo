import 'package:json_annotation/json_annotation.dart';

import 'src/_.dart';

part 'feature_page.g.dart';

@JsonSerializable(createToJson: false)
class FeaturePage {
  final int forumId;
  final String fullName;
  @JsonKey(name: 'is_followed')
  final bool isFollowed;
  final int tagId;
  final String tagText;

  @JsonKey(toJson: none)
  FeaturePageLinks links;

  @JsonKey(toJson: none)
  FeaturePageValues values;

  FeaturePage(
    this.forumId,
    this.fullName,
    this.isFollowed,
    this.tagId,
    this.tagText,
  );
  factory FeaturePage.fromJson(Map<String, dynamic> json) =>
      _$FeaturePageFromJson(json);
}

@JsonSerializable(createToJson: false)
class FeaturePageLinks {
  String follow;
  String image;
  String permalink;

  FeaturePageLinks();
  factory FeaturePageLinks.fromJson(Map<String, dynamic> json) =>
      _$FeaturePageLinksFromJson(json);
}

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class FeaturePageValues {
  int followerCount;
  int newsCount;
  int tagUseCount;
  @JsonKey(name: '7_days_thread_count')
  int xDaysThreadCount;
  @JsonKey(name: '7_days_news_count')
  int xDaysNewsCount;

  FeaturePageValues();
  factory FeaturePageValues.fromJson(Map<String, dynamic> json) =>
      _$FeaturePageValuesFromJson(json);
}

import 'package:json_annotation/json_annotation.dart';

part 'feature_page.g.dart';

final _kIdRegExp = RegExp(r'/([\w-]+)/$');

@JsonSerializable(fieldRename: FieldRename.none)
class FeaturePage {
  final int forumId;
  final String fullName;
  @JsonKey(name: 'is_followed')
  bool isFollowed;
  final int tagId;
  final String tagText;

  FeaturePageLinks links;

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

  // TODO: use data from api when it's available
  String get id {
    final match = _kIdRegExp.firstMatch(links?.permalink ?? '');
    if (match == null) return null;
    return match.group(1);
  }
}

@JsonSerializable()
class FeaturePageLinks {
  String follow;
  String image;
  String permalink;
  String thumbnail;

  FeaturePageLinks();
  factory FeaturePageLinks.fromJson(Map<String, dynamic> json) =>
      _$FeaturePageLinksFromJson(json);
}

@JsonSerializable()
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

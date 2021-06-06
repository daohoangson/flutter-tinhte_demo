import 'package:freezed_annotation/freezed_annotation.dart';

part 'feature_page.freezed.dart';
part 'feature_page.g.dart';

final _kIdRegExp = RegExp(r'/([\w-]+)/$');

@freezed
class FeaturePage with _$FeaturePage {
  @JsonSerializable(fieldRename: FieldRename.none)
  const factory FeaturePage({
    int? forumId,
    String? fullName,
    @JsonKey(name: 'is_followed') bool? isFollowed,
    int? tagId,
    String? tagText,
    FeaturePageLinks? links,
    FeaturePageValues? values,
  }) = _FeaturePage;

  factory FeaturePage.fromJson(Map<String, dynamic> json) =>
      _$FeaturePageFromJson(json);

  const FeaturePage._();

  String? get id {
    // TODO: use data from api when it's available
    final match = _kIdRegExp.firstMatch(links?.permalink ?? '');
    if (match == null) return null;
    return match.group(1);
  }
}

@freezed
class FeaturePageLinks with _$FeaturePageLinks {
  const factory FeaturePageLinks({
    String? follow,
    String? image,
    String? permalink,
    String? thumbnail,
  }) = _FeaturePageLinks;

  factory FeaturePageLinks.fromJson(Map<String, dynamic> json) =>
      _$FeaturePageLinksFromJson(json);
}

@freezed
class FeaturePageValues with _$FeaturePageValues {
  const factory FeaturePageValues({
    int? followerCount,
    int? newsCount,
    int? tagUseCount,
    @JsonKey(name: '7_days_thread_count') int? xDaysThreadCount,
    @JsonKey(name: '7_days_news_count') int? xDaysNewsCount,
  }) = _FeaturePageValues;

  factory FeaturePageValues.fromJson(Map<String, dynamic> json) =>
      _$FeaturePageValuesFromJson(json);
}

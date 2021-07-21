import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'followable.dart';

part 'feature_page.freezed.dart';
part 'feature_page.g.dart';

final _kIdRegExp = RegExp(r'/([\w-]+)/$');

class FeaturePage extends ChangeNotifier implements _FeaturePage, Followable {
  _FeaturePageInternal _;

  FeaturePage.fromJson(Map<String, dynamic> json)
      : _ = _FeaturePageInternal.fromJson(json);

  @Deprecated("Use setters instead of copyWith")
  @override
  _$FeaturePageCopyWith<_FeaturePage> get copyWith =>
      throw UnimplementedError();

  @override
  String? get followersLink => links?.follow;

  @override
  int? get forumId => _.forumId;

  @override
  String? get fullName => _.fullName;

  String? get id {
    // TODO: use data from api when it's available
    final match = _kIdRegExp.firstMatch(links?.permalink ?? '');
    if (match == null) return null;
    return match.group(1);
  }

  @override
  bool get isFollowed => _.isFollowed ?? false;

  @override
  set isFollowed(bool v) {
    if (v == isFollowed) return;

    _ = _.copyWith(isFollowed: v);
    notifyListeners();
  }

  @override
  FeaturePageLinks? get links => _.links;

  @override
  String get name => fullName ?? 'N/A';

  @override
  int? get tagId => _.tagId;

  @override
  String? get tagText => _.tagText;

  @override
  Map<String, dynamic> toJson() => _.toJson();

  @override
  FeaturePageValues? get values => _.values;
}

@freezed
class _FeaturePageInternal with _$_FeaturePageInternal {
  @JsonSerializable(fieldRename: FieldRename.none)
  const factory _FeaturePageInternal(
    int? forumId,
    String? fullName,
    @JsonKey(name: 'is_followed') bool? isFollowed,
    int? tagId,
    String? tagText,
    FeaturePageLinks? links,
    FeaturePageValues? values,
  ) = _FeaturePage;

  factory _FeaturePageInternal.fromJson(Map<String, dynamic> json) =>
      _$_FeaturePageInternalFromJson(json);
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

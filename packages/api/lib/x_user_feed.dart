import 'package:freezed_annotation/freezed_annotation.dart';

part 'x_user_feed.freezed.dart';
part 'x_user_feed.g.dart';

@freezed
class UserFeedData with _$UserFeedData {
  const factory UserFeedData({
    int? feedTime,
    double? score,
    // ignore: invalid_annotation_target
    @JsonKey(name: "_score_weighted") double? scoreWeighted,
    // ignore: invalid_annotation_target
    @JsonKey(name: "_sort_bucket") String? sortBucket,
    // ignore: invalid_annotation_target
    @JsonKey(name: "_sources") Map<String, int>? sources,
  }) = _UserFeedData;

  factory UserFeedData.fromJson(Map<String, dynamic> json) =>
      _$UserFeedDataFromJson(json);
}

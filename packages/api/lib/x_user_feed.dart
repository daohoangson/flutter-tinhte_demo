import 'package:freezed_annotation/freezed_annotation.dart';

part 'x_user_feed.freezed.dart';
part 'x_user_feed.g.dart';

@freezed
class UserFeedData with _$UserFeedData {
  const factory UserFeedData({
    int? feedTime,
    double? score,
    @JsonKey(name: "_score_weighted") double? scoreWeighted,
    @JsonKey(name: "_sort_bucket") String? sortBucket,
    @JsonKey(name: "_sources") Map<String, int>? sources,
  }) = _UserFeedData;

  factory UserFeedData.fromJson(Map<String, dynamic> json) =>
      _$UserFeedDataFromJson(json);
}

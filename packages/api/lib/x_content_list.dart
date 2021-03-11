import 'package:freezed_annotation/freezed_annotation.dart';

part 'x_content_list.freezed.dart';
part 'x_content_list.g.dart';

@freezed
class ContentListItem with _$ContentListItem {
  const factory ContentListItem(
    int itemId, {
    String? itemTitle,
    int? itemDate,
    int? userId,
  }) = _ContentListItem;

  factory ContentListItem.fromJson(Map<String, dynamic> json) =>
      _$ContentListItemFromJson(json);
}

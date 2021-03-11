import 'package:freezed_annotation/freezed_annotation.dart';

part 'tag.freezed.dart';
part 'tag.g.dart';

@freezed
class Tag with _$Tag {
  const factory Tag(
    int tagId, {
    bool? tagIsFollowed,
    String? tagText,
    int? tagUseCount,
    TagLinks? links,
    TagPermissions? permissions,
  }) = _Tag;

  factory Tag.fromJson(Map<String, dynamic> json) => _$TagFromJson(json);
}

@freezed
class TagLinks with _$TagLinks {
  const factory TagLinks({
    String? detail,
    String? followers,
    String? permalink,
  }) = _TagLinks;

  factory TagLinks.fromJson(Map<String, dynamic> json) =>
      _$TagLinksFromJson(json);
}

@freezed
class TagPermissions with _$TagPermissions {
  const factory TagPermissions({
    bool? follow,
  }) = _TagPermissions;

  factory TagPermissions.fromJson(Map<String, dynamic> json) =>
      _$TagPermissionsFromJson(json);
}

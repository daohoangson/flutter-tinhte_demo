import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'followable.dart';

part 'tag.freezed.dart';
part 'tag.g.dart';

class Tag extends ChangeNotifier implements _Tag, Followable {
  _TagInternal _;

  Tag.fromJson(Map<String, dynamic> json) : _ = _TagInternal.fromJson(json);

  @Deprecated("Use setters instead of copyWith")
  @override
  _$TagCopyWith<_Tag> get copyWith => throw UnimplementedError();

  @override
  String? get followersLink => links?.followers;

  @override
  bool get isFollowed => tagIsFollowed ?? false;

  @override
  set isFollowed(bool v) {
    if (v == isFollowed) return;

    _ = _.copyWith(tagIsFollowed: v);
    notifyListeners();
  }

  @override
  TagLinks? get links => _.links;

  @override
  String get name => "#$tagText";

  @override
  TagPermissions? get permissions => _.permissions;

  @override
  int get tagId => _.tagId;

  @override
  bool? get tagIsFollowed => _.tagIsFollowed;

  @override
  String? get tagText => _.tagText;

  @override
  int? get tagUseCount => _.tagUseCount;

  @override
  Map<String, dynamic> toJson() => _.toJson();
}

@freezed
class _TagInternal with _$_TagInternal {
  const factory _TagInternal(
    int tagId,
    bool? tagIsFollowed,
    String? tagText,
    int? tagUseCount,
    TagLinks? links,
    TagPermissions? permissions,
  ) = _Tag;

  factory _TagInternal.fromJson(Map<String, dynamic> json) =>
      _$_TagInternalFromJson(json);
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

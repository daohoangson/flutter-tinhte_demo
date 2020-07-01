import 'package:json_annotation/json_annotation.dart';

part 'tag.g.dart';

@JsonSerializable()
class Tag {
  final int tagId;
  bool tagIsFollowed;
  String tagText;
  int tagUseCount;

  TagLinks links;

  TagPermissions permissions;

  Tag(this.tagId);
  factory Tag.fromJson(Map<String, dynamic> json) => _$TagFromJson(json);
}

@JsonSerializable()
class TagLinks {
  String detail;
  String followers;
  String permalink;

  TagLinks();
  factory TagLinks.fromJson(Map<String, dynamic> json) =>
      _$TagLinksFromJson(json);
}

@JsonSerializable()
class TagPermissions {
  bool follow;

  TagPermissions();
  factory TagPermissions.fromJson(Map<String, dynamic> json) =>
      _$TagPermissionsFromJson(json);
}

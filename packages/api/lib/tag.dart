import 'package:json_annotation/json_annotation.dart';

import 'src/_.dart';

part 'tag.g.dart';

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class Tag {
  final int tagId;
  bool tagIsFollowed;
  String tagText;
  int tagUseCount;

  @JsonKey(toJson: none)
  TagLinks links;

  @JsonKey(toJson: none)
  TagPermissions permissions;

  Tag(this.tagId);
  factory Tag.fromJson(Map<String, dynamic> json) => _$TagFromJson(json);
}

@JsonSerializable(createToJson: false)
class TagLinks {
  String detail;
  String followers;
  String permalink;

  TagLinks();
  factory TagLinks.fromJson(Map<String, dynamic> json) =>
      _$TagLinksFromJson(json);
}

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class TagPermissions {
  bool follow;

  TagPermissions();
  factory TagPermissions.fromJson(Map<String, dynamic> json) =>
      _$TagPermissionsFromJson(json);
}

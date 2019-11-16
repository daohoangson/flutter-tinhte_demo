// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Tag _$TagFromJson(Map<String, dynamic> json) {
  return Tag(json['tag_id'] as int)
    ..tagIsFollowed = json['tag_is_followed'] as bool
    ..tagText = json['tag_text'] as String
    ..tagUseCount = json['tag_use_count'] as int
    ..links = json['links'] == null
        ? null
        : TagLinks.fromJson(json['links'] as Map<String, dynamic>)
    ..permissions = json['permissions'] == null
        ? null
        : TagPermissions.fromJson(json['permissions'] as Map<String, dynamic>);
}

TagLinks _$TagLinksFromJson(Map<String, dynamic> json) {
  return TagLinks()
    ..detail = json['detail'] as String
    ..followers = json['followers'] as String
    ..permalink = json['permalink'] as String;
}

TagPermissions _$TagPermissionsFromJson(Map<String, dynamic> json) {
  return TagPermissions()..follow = json['follow'] as bool;
}

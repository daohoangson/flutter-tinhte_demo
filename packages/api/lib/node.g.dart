// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Category _$CategoryFromJson(Map<String, dynamic> json) {
  return Category(
    json['category_id'] as int,
  )
    ..categoryDescription = json['category_description'] as String
    ..categoryTitle = json['category_title'] as String
    ..links = json['links'] == null
        ? null
        : CategoryLinks.fromJson(json['links'] as Map<String, dynamic>)
    ..permissions = json['permissions'] == null
        ? null
        : CategoryPermissions.fromJson(
            json['permissions'] as Map<String, dynamic>);
}

CategoryLinks _$CategoryLinksFromJson(Map<String, dynamic> json) {
  return CategoryLinks()
    ..detail = json['detail'] as String
    ..permalink = json['permalink'] as String;
}

CategoryPermissions _$CategoryPermissionsFromJson(Map<String, dynamic> json) {
  return CategoryPermissions()
    ..delete = json['delete'] as bool
    ..edit = json['edit'] as bool
    ..view = json['view'] as bool;
}

Forum _$ForumFromJson(Map<String, dynamic> json) {
  return Forum(
    json['forum_id'] as int,
  )
    ..forumDescription = json['forum_description'] as String
    ..forumIsFollowed = json['forum_is_followed'] as bool
    ..forumPostCount = json['forum_post_count'] as int
    ..forumPrefixes = (json['forum_prefixes'] as List)
        ?.map((e) =>
            e == null ? null : ThreadPrefix.fromJson(e as Map<String, dynamic>))
        ?.toList()
    ..forumThreadCount = json['forum_thread_count'] as int
    ..forumTitle = json['forum_title'] as String
    ..links = json['links'] == null
        ? null
        : ForumLinks.fromJson(json['links'] as Map<String, dynamic>)
    ..permissions = json['permissions'] == null
        ? null
        : ForumPermissions.fromJson(json['permissions'] as Map<String, dynamic>)
    ..threadDefaultPrefixId = json['thread_default_prefix_id'] as int
    ..threadPrefixIsRequired = json['thread_prefix_is_required'] as bool;
}

ForumLinks _$ForumLinksFromJson(Map<String, dynamic> json) {
  return ForumLinks()
    ..detail = json['detail'] as String
    ..followers = json['followers'] as String
    ..permalink = json['permalink'] as String
    ..threads = json['threads'] as String;
}

ForumPermissions _$ForumPermissionsFromJson(Map<String, dynamic> json) {
  return ForumPermissions()
    ..createThread = json['create_thread'] as bool
    ..delete = json['delete'] as bool
    ..edit = json['edit'] as bool
    ..follow = json['follow'] as bool
    ..tagThread = json['tag_thread'] as bool
    ..uploadAttachment = json['upload_attachment'] as bool
    ..view = json['view'] as bool;
}

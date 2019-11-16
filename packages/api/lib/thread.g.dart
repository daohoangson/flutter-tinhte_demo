// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Thread _$ThreadFromJson(Map<String, dynamic> json) {
  return Thread(json['thread_id'] as int)
    ..creatorHasVerifiedBadge = json['creator_has_verified_badge'] as bool
    ..creatorUserId = json['creator_user_id'] as int
    ..creatorUsername = json['creator_username'] as String
    ..forumId = json['forum_id'] as int
    ..firstPost = json['first_post'] == null
        ? null
        : Post.fromJson(json['first_post'] as Map<String, dynamic>)
    ..threadCreateDate = json['thread_create_date'] as int
    ..threadIsDeleted = json['thread_is_deleted'] as bool
    ..threadIsFollowed = json['thread_is_followed'] as bool
    ..threadIsPublished = json['thread_is_published'] as bool
    ..threadIsSticky = json['thread_is_sticky'] as bool
    ..threadPostCount = json['thread_post_count'] as int
    ..threadTags = json['thread_tags'] == null
        ? null
        : _threadTagsFromJson(json['thread_tags'])
    ..threadTitle = json['thread_title'] as String
    ..threadUpdateDate = json['thread_update_date'] as int
    ..threadViewCount = json['thread_view_count'] as int
    ..userIsIgnored = json['user_is_ignored'] as bool
    ..forum = json['forum'] == null
        ? null
        : Forum.fromJson(json['forum'] as Map<String, dynamic>)
    ..links = json['links'] == null
        ? null
        : ThreadLinks.fromJson(json['links'] as Map<String, dynamic>)
    ..permissions = json['permissions'] == null
        ? null
        : ThreadPermissions.fromJson(
            json['permissions'] as Map<String, dynamic>)
    ..threadImage = json['thread_image'] == null
        ? null
        : ThreadImage.fromJson(json['thread_image'] as Map<String, dynamic>)
    ..threadPrefixes = (json['thread_prefixes'] as List)
        ?.map((e) =>
            e == null ? null : ThreadPrefix.fromJson(e as Map<String, dynamic>))
        ?.toList()
    ..threadThumbnail = json['thread_thumbnail'] == null
        ? null
        : ThreadImage.fromJson(
            json['thread_thumbnail'] as Map<String, dynamic>);
}

Map<String, dynamic> _$ThreadToJson(Thread instance) => <String, dynamic>{
      'creator_has_verified_badge': instance.creatorHasVerifiedBadge,
      'creator_user_id': instance.creatorUserId,
      'creator_username': instance.creatorUsername,
      'forum_id': instance.forumId,
      'first_post': instance.firstPost,
      'thread_create_date': instance.threadCreateDate,
      'thread_id': instance.threadId,
      'thread_is_deleted': instance.threadIsDeleted,
      'thread_is_followed': instance.threadIsFollowed,
      'thread_is_published': instance.threadIsPublished,
      'thread_is_sticky': instance.threadIsSticky,
      'thread_post_count': instance.threadPostCount,
      'thread_tags': instance.threadTags,
      'thread_title': instance.threadTitle,
      'thread_update_date': instance.threadUpdateDate,
      'thread_view_count': instance.threadViewCount,
      'user_is_ignored': instance.userIsIgnored,
      'forum': instance.forum == null ? null : none(instance.forum),
      'links': instance.links == null ? null : none(instance.links),
      'permissions':
          instance.permissions == null ? null : none(instance.permissions),
      'thread_image':
          instance.threadImage == null ? null : none(instance.threadImage),
      'thread_prefixes': instance.threadPrefixes == null
          ? null
          : none(instance.threadPrefixes),
      'thread_thumbnail': instance.threadThumbnail == null
          ? null
          : none(instance.threadThumbnail)
    };

ThreadImage _$ThreadImageFromJson(Map<String, dynamic> json) {
  return ThreadImage(json['link'] as String)
    ..displayMode = json['display_mode'] as String
    ..height = json['height'] as int
    ..mode = json['mode'] as String
    ..size = json['size'] as int
    ..width = json['width'] as int;
}

ThreadLinks _$ThreadLinksFromJson(Map<String, dynamic> json) {
  return ThreadLinks()
    ..detail = json['detail'] as String
    ..firstPost = json['first_post'] as String
    ..firstPoster = json['first_poster'] as String
    ..firstPosterAvatar = json['first_poster_avatar'] as String
    ..followers = json['followers'] as String
    ..forum = json['forum'] as String
    ..image = json['image'] as String
    ..lastPost = json['last_post'] as String
    ..lastPoster = json['last_poster'] as String
    ..permalink = json['permalink'] as String
    ..posts = json['posts'] as String;
}

ThreadPermissions _$ThreadPermissionsFromJson(Map<String, dynamic> json) {
  return ThreadPermissions()
    ..delete = json['delete'] as bool
    ..edit = json['edit'] as bool
    ..follow = json['follow'] as bool
    ..post = json['post'] as bool
    ..uploadAttachment = json['upload_attachment'] as bool
    ..view = json['view'] as bool;
}

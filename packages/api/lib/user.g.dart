// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) {
  return User(json['user_id'] as int)
    ..userHasVerifiedBadge = json['user_has_verified_badge'] as bool
    ..userIsFollowed = json['user_is_followed'] as bool
    ..userIsIgnored = json['user_is_ignored'] as bool
    ..userIsValid = json['user_is_valid'] as bool
    ..userIsVerified = json['user_is_verified'] as bool
    ..userIsVisitor = json['user_is_visitor'] as bool
    ..userLastSeenDate = json['user_last_seen_date'] as int
    ..userLikeCount = json['user_like_count'] as int
    ..userMessageCount = json['user_message_count'] as int
    ..userRegisterDate = json['user_register_date'] as int
    ..userTitle = json['user_title'] as String
    ..userUnreadNotificationCount =
        json['user_unread_notification_count'] as int
    ..username = json['username'] as String
    ..links = json['links'] == null
        ? null
        : UserLinks.fromJson(json['links'] as Map<String, dynamic>)
    ..permissions = json['permissions'] == null
        ? null
        : UserPermissions.fromJson(json['permissions'] as Map<String, dynamic>)
    ..rank = json['rank'] == null
        ? null
        : UserRank.fromJson(json['rank'] as Map<String, dynamic>);
}

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'user_id': instance.userId,
      'user_has_verified_badge': instance.userHasVerifiedBadge,
      'user_is_followed': instance.userIsFollowed,
      'user_is_ignored': instance.userIsIgnored,
      'user_is_valid': instance.userIsValid,
      'user_is_verified': instance.userIsVerified,
      'user_is_visitor': instance.userIsVisitor,
      'user_last_seen_date': instance.userLastSeenDate,
      'user_like_count': instance.userLikeCount,
      'user_message_count': instance.userMessageCount,
      'user_register_date': instance.userRegisterDate,
      'user_title': instance.userTitle,
      'user_unread_notification_count': instance.userUnreadNotificationCount,
      'username': instance.username,
      'links': instance.links == null ? null : none(instance.links),
      'permissions':
          instance.permissions == null ? null : none(instance.permissions),
      'rank': instance.rank == null ? null : none(instance.rank)
    };

UserLinks _$UserLinksFromJson(Map<String, dynamic> json) {
  return UserLinks()
    ..avatar = json['avatar'] as String
    ..avatarBig = json['avatar_big'] as String
    ..avatarSmall = json['avatar_small'] as String
    ..detail = json['detail'] as String
    ..followers = json['followers'] as String
    ..followings = json['followings'] as String
    ..ignore = json['ignore'] as String
    ..permalink = json['permalink'] as String
    ..timeline = json['timeline'] as String;
}

UserPermissions _$UserPermissionsFromJson(Map<String, dynamic> json) {
  return UserPermissions()
    ..edit = json['edit'] as bool
    ..follow = json['follow'] as bool
    ..ignore = json['ignore'] as bool
    ..profilePost = json['profile_post'] as bool;
}

UserRank _$UserRankFromJson(Map<String, dynamic> json) {
  return UserRank()
    ..rankGroupId = json['rank_group_id'] as int
    ..rankLevel = json['rank_level'] as int
    ..rankName = json['rank_name'] as String;
}

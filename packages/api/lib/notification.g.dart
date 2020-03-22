// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Notification _$NotificationFromJson(Map<String, dynamic> json) {
  return Notification(
    json['notification_id'] as int,
  )
    ..contentAction = json['content_action'] as String
    ..contentId = json['content_id'] as int
    ..contentType = json['content_type'] as String
    ..creatorUserId = json['creator_user_id'] as int
    ..creatorUsername = json['creator_username'] as String
    ..notificationCreateDate = json['notification_create_date'] as int
    ..notificationHtml = json['notification_html'] as String
    ..notificationIsUnread = json['notification_is_unread'] as bool
    ..notificationType = json['notification_type'] as String
    ..links = json['links'] == null
        ? null
        : NotificationLinks.fromJson(json['links'] as Map<String, dynamic>);
}

NotificationLinks _$NotificationLinksFromJson(Map<String, dynamic> json) {
  return NotificationLinks()
    ..content = json['content'] as String
    ..creatorAvatar = json['creator_avatar'] as String;
}

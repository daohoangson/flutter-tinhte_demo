import 'package:json_annotation/json_annotation.dart';

part 'notification.g.dart';

@JsonSerializable()
class Notification {
  String contentAction;
  int contentId;
  String contentType;
  int creatorUserId;
  String creatorUsername;
  int notificationCreateDate;
  String notificationHtml;
  final int notificationId;
  bool notificationIsUnread;
  String notificationType;

  NotificationLinks links;

  Notification(this.notificationId);
  factory Notification.fromJson(Map<String, dynamic> json) =>
      _$NotificationFromJson(json);
}

@JsonSerializable()
class NotificationLinks {
  String content;
  String creatorAvatar;

  NotificationLinks();
  factory NotificationLinks.fromJson(Map<String, dynamic> json) =>
      _$NotificationLinksFromJson(json);
}

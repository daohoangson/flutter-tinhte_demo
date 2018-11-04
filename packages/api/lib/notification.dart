import 'package:json_annotation/json_annotation.dart';

import 'src/_.dart';

part 'notification.g.dart';

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
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

  @JsonKey(toJson: none)
  NotificationLinks links;

  Notification(this.notificationId);
  factory Notification.fromJson(Map<String, dynamic> json) =>
      _$NotificationFromJson(json);
}

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class NotificationLinks {
  String content;
  String creatorAvatar;

  NotificationLinks();
  factory NotificationLinks.fromJson(Map<String, dynamic> json) =>
      _$NotificationLinksFromJson(json);
}

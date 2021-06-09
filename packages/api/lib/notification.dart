import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification.freezed.dart';
part 'notification.g.dart';

@freezed
class Notification with _$Notification {
  const factory Notification(
    int notificationId, {
    String? contentAction,
    int? contentId,
    String? contentType,
    int? creatorUserId,
    String? creatorUsername,
    int? notificationCreateDate,
    String? notificationHtml,
    bool? notificationIsUnread,
    String? notificationType,
    NotificationLinks? links,
  }) = _Notification;

  factory Notification.fromJson(Map<String, dynamic> json) =>
      _$NotificationFromJson(json);
}

@freezed
class NotificationLinks with _$NotificationLinks {
  const factory NotificationLinks({
    String? content,
    String? creatorAvatar,
  }) = _NotificationLinks;

  factory NotificationLinks.fromJson(Map<String, dynamic> json) =>
      _$NotificationLinksFromJson(json);
}

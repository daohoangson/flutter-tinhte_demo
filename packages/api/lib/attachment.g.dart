// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attachment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Attachment _$AttachmentFromJson(Map<String, dynamic> json) {
  return Attachment(
    json['attachment_id'] as int,
  )
    ..attachmentDownloadCount = json['attachment_download_count'] as int
    ..attachmentHeight = json['attachment_height'] as int
    ..attachmentIsInserted = json['attachment_is_inserted'] as bool
    ..attachmentWidth = json['attachment_width'] as int
    ..filename = json['filename'] as String
    ..links = json['links'] == null
        ? null
        : AttachmentLinks.fromJson(json['links'] as Map<String, dynamic>)
    ..permissions = json['permissions'] == null
        ? null
        : AttachmentPermissions.fromJson(
            json['permissions'] as Map<String, dynamic>);
}

AttachmentLinks _$AttachmentLinksFromJson(Map<String, dynamic> json) {
  return AttachmentLinks()
    ..permalink = json['permalink'] as String
    ..data = json['data'] as String
    ..thumbnail = json['thumbnail'] as String;
}

AttachmentPermissions _$AttachmentPermissionsFromJson(
    Map<String, dynamic> json) {
  return AttachmentPermissions()
    ..view = json['view'] as bool
    ..delete = json['delete'] as bool;
}

import 'package:json_annotation/json_annotation.dart';

part 'attachment.g.dart';

@JsonSerializable()
class Attachment {
  int attachmentDownloadCount;
  final int attachmentId;
  int attachmentHeight;
  bool attachmentIsInserted;
  int attachmentWidth;
  String filename;

  AttachmentLinks links;

  AttachmentPermissions permissions;

  Attachment(this.attachmentId);
  factory Attachment.fromJson(Map<String, dynamic> json) =>
      _$AttachmentFromJson(json);
}

@JsonSerializable()
class AttachmentLinks {
  String permalink;
  String data;
  String thumbnail;

  AttachmentLinks();
  factory AttachmentLinks.fromJson(Map<String, dynamic> json) =>
      _$AttachmentLinksFromJson(json);
}

@JsonSerializable()
class AttachmentPermissions {
  bool view;
  bool delete;

  AttachmentPermissions();
  factory AttachmentPermissions.fromJson(Map<String, dynamic> json) =>
      _$AttachmentPermissionsFromJson(json);
}

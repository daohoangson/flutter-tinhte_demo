import 'package:json_annotation/json_annotation.dart';

import 'src/_.dart';

part 'attachment.g.dart';

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class Attachment {
  int attachmentDownloadCount;
  final int attachmentId;
  int attachmentHeight;
  bool attachmentIsInserted;
  int attachmentWidth;
  String filename;

  @JsonKey(toJson: none)
  AttachmentLinks links;

  @JsonKey(toJson: none)
  AttachmentPermissions permissions;

  Attachment(this.attachmentId);
  factory Attachment.fromJson(Map<String, dynamic> json) =>
      _$AttachmentFromJson(json);
}

@JsonSerializable(createToJson: false)
class AttachmentLinks {
  String permalink;
  String data;
  String thumbnail;

  AttachmentLinks();
  factory AttachmentLinks.fromJson(Map<String, dynamic> json) =>
      _$AttachmentLinksFromJson(json);
}

@JsonSerializable(createToJson: false)
class AttachmentPermissions {
  bool view;
  bool delete;

  AttachmentPermissions();
  factory AttachmentPermissions.fromJson(Map<String, dynamic> json) =>
      _$AttachmentPermissionsFromJson(json);
}

import 'package:freezed_annotation/freezed_annotation.dart';

part 'attachment.freezed.dart';
part 'attachment.g.dart';

@freezed
class Attachment with _$Attachment {
  const factory Attachment(
    int attachmentId, {
    int? attachmentDownloadCount,
    int? attachmentHeight,
    bool? attachmentIsInserted,
    int? attachmentWidth,
    String? filename,
    AttachmentLinks? links,
    AttachmentPermissions? permissions,
  }) = _Attachment;

  factory Attachment.fromJson(Map<String, dynamic> json) =>
      _$AttachmentFromJson(json);
}

@freezed
class AttachmentLinks with _$AttachmentLinks {
  const factory AttachmentLinks({
    String? permalink,
    String? data,
    String? thumbnail,
  }) = _AttachmentLinks;

  factory AttachmentLinks.fromJson(Map<String, dynamic> json) =>
      _$AttachmentLinksFromJson(json);
}

@freezed
class AttachmentPermissions with _$AttachmentPermissions {
  const factory AttachmentPermissions({
    bool? view,
    bool? delete,
  }) = _AttachmentPermissions;

  factory AttachmentPermissions.fromJson(Map<String, dynamic> json) =>
      _$AttachmentPermissionsFromJson(json);
}

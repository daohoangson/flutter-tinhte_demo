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
    // ignore: invalid_annotation_target
    @JsonKey(name: 'attachment_is_video') bool? xVideoIsVideo,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'attachment_video_is_processing') bool? xVideoIsProcessing,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'video_ratio') double? xVideoRatio,
  }) = _Attachment;

  factory Attachment.fromJson(Map<String, dynamic> json) =>
      _$AttachmentFromJson(json);

  const Attachment._();

  double? get aspectRatio {
    if (isImage) {
      return attachmentWidth! / attachmentHeight!;
    } else if (isVideo) {
      return xVideoRatio;
    }

    return null;
  }

  bool get isImage {
    final width = attachmentWidth ?? 0.0;
    final height = attachmentHeight ?? 0.0;
    return width > 0 && height > 0;
  }

  bool get isVideo => xVideoIsVideo == true;
}

@freezed
class AttachmentLinks with _$AttachmentLinks {
  const factory AttachmentLinks({
    String? permalink,
    String? data,
    String? thumbnail,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'video_url') String? xVideoUrl,
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

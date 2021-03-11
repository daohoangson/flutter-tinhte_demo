import 'package:freezed_annotation/freezed_annotation.dart';

import 'attachment.dart';
import 'user.dart';

part 'post.freezed.dart';
part 'post.g.dart';

@freezed
class Post with _$Post {
  const factory Post(
    int postId, {
    int? postAttachmentCount,
    String? postBody,
    String? postBodyHtml,
    String? postBodyPlainText,
    int? postCreateDate,
    bool? postIsDeleted,
    bool? postIsFirstPost,
    bool? postIsLiked,
    bool? postIsPublished,
    int? postLikeCount,
    int? postUpdateDate,
    bool? posterHasVerifiedBadge,
    int? posterUserId,
    String? posterUsername,
    String? signature,
    String? signatureHtml,
    String? signaturePlainText,
    int? threadId,
    bool? userIsIgnored,
    @Default(const []) List<Attachment> attachments,
    PostLinks? links,
    PostPermissions? permissions,
    @Default(const []) List<PostReply> postReplies,
    bool? postHasOtherReplies,
    int? postReplyTo,
    int? postReplyDepth,
    UserRank? posterRank,
  }) = _Post;

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);
}

@freezed
class PostLinks with _$PostLinks {
  const factory PostLinks({
    String? attachments,
    String? detail,
    String? likes,
    String? permalink,
    String? poster,
    String? posterAvatar,
    String? report,
    String? thread,
  }) = _PostLinks;

  factory PostLinks.fromJson(Map<String, dynamic> json) =>
      _$PostLinksFromJson(json);
}

@freezed
class PostPermissions with _$PostPermissions {
  const factory PostPermissions({
    bool? delete,
    bool? edit,
    bool? like,
    bool? reply,
    bool? report,
    bool? uploadAttachment,
    bool? view,
  }) = _PostPermissions;

  factory PostPermissions.fromJson(Map<String, dynamic> json) =>
      _$PostPermissionsFromJson(json);
}

@freezed
class PostReply with _$PostReply {
  const factory PostReply({
    int? from,
    String? link,
    int? postId,
    int? postReplyCount,
    int? postReplyDepth,
    int? postReplyTo,
    int? to,
  }) = _PostReply;

  factory PostReply.fromJson(Map<String, dynamic> json) =>
      _$PostReplyFromJson(json);
}

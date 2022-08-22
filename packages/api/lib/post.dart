import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'attachment.dart';
import 'user.dart';
import 'x_post_sticker.dart';

part 'post.freezed.dart';
part 'post.g.dart';

class Post extends ChangeNotifier implements _PostInternal {
  _PostInternal _;

  Post.fromJson(Map<String, dynamic> json) : _ = _PostInternal.fromJson(json);

  @override
  List<Attachment> get attachments => _.attachments ?? const [];

  @Deprecated("Use setters instead of copyWith")
  @override
  // ignore: library_private_types_in_public_api
  _$PostInternalCopyWith<_PostInternal> get copyWith =>
      throw UnimplementedError();

  @override
  PostLinks? get links => _.links;

  @override
  PostPermissions? get permissions => _.permissions;

  @override
  int? get postAttachmentCount => _.postAttachmentCount;

  @override
  String? get postBody => _.postBody;

  @override
  String? get postBodyHtml => _.postBodyHtml;

  @override
  String? get postBodyPlainText => _.postBodyPlainText;

  @override
  int? get postCreateDate => _.postCreateDate;

  @override
  bool? get postHasOtherReplies => _.postHasOtherReplies;

  @override
  int get postId => _.postId;

  @override
  bool get postIsDeleted => _.postIsDeleted ?? false;

  set postIsDeleted(bool v) {
    if (v == postIsDeleted) return;

    _ = _.copyWith(postIsDeleted: v);
    notifyListeners();
  }

  @override
  bool? get postIsFirstPost => _.postIsFirstPost;

  @override
  bool get postIsLiked => _.postIsLiked ?? false;

  set postIsLiked(bool v) {
    if (v == postIsLiked) return;

    final oldCount = postLikeCount ?? 0;
    final newCount = max(0, oldCount + (v ? 1 : -1));
    _ = _.copyWith(postIsLiked: v, postLikeCount: newCount);
    notifyListeners();
  }

  @override
  bool? get postIsPublished => _.postIsPublished;

  @override
  int? get postLikeCount => _.postLikeCount;

  @override
  List<PostReply> get postReplies => _.postReplies ?? const [];

  @override
  int? get postReplyDepth => _.postReplyDepth;

  @override
  int? get postReplyTo => _.postReplyTo;

  @override
  int? get postUpdateDate => _.postUpdateDate;

  @override
  bool? get posterHasVerifiedBadge => _.posterHasVerifiedBadge;

  @override
  UserRank? get posterRank => _.posterRank;

  @override
  int? get posterUserId => _.posterUserId;

  @override
  String? get posterUsername => _.posterUsername;

  @override
  String? get signature => _.signature;

  @override
  String? get signatureHtml => _.signatureHtml;

  @override
  String? get signaturePlainText => _.signaturePlainText;

  @override
  List<PostSticker>? get stickers => _.stickers;

  @override
  int? get threadId => _.threadId;

  @override
  Map<String, dynamic> toJson() => _.toJson();

  @override
  bool? get userIsIgnored => _.userIsIgnored;
}

@freezed
class _PostInternal with _$_PostInternal {
  const factory _PostInternal(
    int postId,
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
    List<Attachment>? attachments,
    PostLinks? links,
    PostPermissions? permissions,
    List<PostReply>? postReplies,
    bool? postHasOtherReplies,
    int? postReplyTo,
    int? postReplyDepth,
    UserRank? posterRank,
    List<PostSticker>? stickers,
  ) = _Post;

  factory _PostInternal.fromJson(Map<String, dynamic> json) =>
      _$_PostInternalFromJson(json);
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

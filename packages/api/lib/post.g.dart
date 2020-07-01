// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Post _$PostFromJson(Map<String, dynamic> json) {
  return Post(
    json['post_id'] as int,
  )
    ..postAttachmentCount = json['post_attachment_count'] as int
    ..postBody = json['post_body'] as String
    ..postBodyHtml = json['post_body_html'] as String
    ..postBodyPlainText = json['post_body_plain_text'] as String
    ..postCreateDate = json['post_create_date'] as int
    ..postIsDeleted = json['post_is_deleted'] as bool
    ..postIsFirstPost = json['post_is_first_post'] as bool
    ..postIsLiked = json['post_is_liked'] as bool
    ..postIsPublished = json['post_is_published'] as bool
    ..postLikeCount = json['post_like_count'] as int
    ..postUpdateDate = json['post_update_date'] as int
    ..posterHasVerifiedBadge = json['poster_has_verified_badge'] as bool
    ..posterUserId = json['poster_user_id'] as int
    ..posterUsername = json['poster_username'] as String
    ..signature = json['signature'] as String
    ..signatureHtml = json['signature_html'] as String
    ..signaturePlainText = json['signature_plain_text'] as String
    ..threadId = json['thread_id'] as int
    ..userIsIgnored = json['user_is_ignored'] as bool
    ..attachments = (json['attachments'] as List)
        ?.map((e) =>
            e == null ? null : Attachment.fromJson(e as Map<String, dynamic>))
        ?.toList()
    ..links = json['links'] == null
        ? null
        : PostLinks.fromJson(json['links'] as Map<String, dynamic>)
    ..permissions = json['permissions'] == null
        ? null
        : PostPermissions.fromJson(json['permissions'] as Map<String, dynamic>)
    ..postReplies = (json['post_replies'] as List)
        ?.map((e) =>
            e == null ? null : PostReply.fromJson(e as Map<String, dynamic>))
        ?.toList()
    ..postHasOtherReplies = json['post_has_other_replies'] as bool
    ..postReplyTo = json['post_reply_to'] as int
    ..postReplyDepth = json['post_reply_depth'] as int
    ..posterRank = json['poster_rank'] == null
        ? null
        : UserRank.fromJson(json['poster_rank'] as Map<String, dynamic>);
}

PostLinks _$PostLinksFromJson(Map<String, dynamic> json) {
  return PostLinks()
    ..attachments = json['attachments'] as String
    ..detail = json['detail'] as String
    ..likes = json['likes'] as String
    ..permalink = json['permalink'] as String
    ..poster = json['poster'] as String
    ..posterAvatar = json['poster_avatar'] as String
    ..report = json['report'] as String
    ..thread = json['thread'] as String;
}

PostPermissions _$PostPermissionsFromJson(Map<String, dynamic> json) {
  return PostPermissions()
    ..delete = json['delete'] as bool
    ..edit = json['edit'] as bool
    ..like = json['like'] as bool
    ..reply = json['reply'] as bool
    ..report = json['report'] as bool
    ..uploadAttachment = json['upload_attachment'] as bool
    ..view = json['view'] as bool;
}

PostReply _$PostReplyFromJson(Map<String, dynamic> json) {
  return PostReply()
    ..from = json['from'] as int
    ..link = json['link'] as String
    ..postId = json['post_id'] as int
    ..postReplyCount = json['post_reply_count'] as int
    ..postReplyDepth = json['post_reply_depth'] as int
    ..postReplyTo = json['post_reply_to'] as int
    ..to = json['to'] as int;
}

import 'package:json_annotation/json_annotation.dart';

import 'attachment.dart';
import 'user.dart';

part 'post.g.dart';

@JsonSerializable()
class Post {
  int postAttachmentCount;
  String postBody;
  String postBodyHtml;
  String postBodyPlainText;
  int postCreateDate;
  final int postId;
  bool postIsDeleted;
  bool postIsFirstPost;
  bool postIsLiked;
  bool postIsPublished;
  int postLikeCount;
  int postUpdateDate;
  bool posterHasVerifiedBadge;
  int posterUserId;
  String posterUsername;
  String signature;
  String signatureHtml;
  String signaturePlainText;
  int threadId;
  bool userIsIgnored;

  List<Attachment> attachments;
  PostLinks links;
  PostPermissions permissions;

  List<PostReply> postReplies;
  bool postHasOtherReplies;
  int postReplyTo;
  int postReplyDepth;

  UserRank posterRank;

  Post(this.postId);
  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);
}

@JsonSerializable()
class PostLinks {
  String attachments;
  String detail;
  String likes;
  String permalink;
  String poster;
  String posterAvatar;
  String report;
  String thread;

  PostLinks();
  factory PostLinks.fromJson(Map<String, dynamic> json) =>
      _$PostLinksFromJson(json);
}

@JsonSerializable()
class PostPermissions {
  bool delete;
  bool edit;
  bool like;
  bool reply;
  bool report;
  bool uploadAttachment;
  bool view;

  PostPermissions();
  factory PostPermissions.fromJson(Map<String, dynamic> json) =>
      _$PostPermissionsFromJson(json);
}

@JsonSerializable()
class PostReply {
  int from;
  String link;
  int postId;
  int postReplyCount;
  int postReplyDepth;
  int postReplyTo;
  int to;

  PostReply();
  factory PostReply.fromJson(Map<String, dynamic> json) =>
      _$PostReplyFromJson(json);
}

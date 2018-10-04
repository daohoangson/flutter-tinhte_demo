import 'package:json_annotation/json_annotation.dart';

import '_.dart';

part 'post.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
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
  int posterUserId;
  String posterUsername;
  String signature;
  String signatureHtml;
  String signaturePlainText;
  int threadId;
  bool userIsIgnored;

  @JsonKey(toJson: none)
  PostLinks links;

  @JsonKey(toJson: none)
  PostPermissions permissions;

  Post(this.postId);
  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);
  Map<String, dynamic> toJson() => _$PostToJson(this);
}

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
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

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
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
import 'package:json_annotation/json_annotation.dart';

import 'src/_.dart';
import 'attachment.dart';

part 'post.g.dart';

List<Post> decodePostsAndTheirReplies(List<dynamic> jsonPosts) {
  List<Post> posts = List();

  jsonPosts.forEach((jsonPost) {
    final post = Post.fromJson(jsonPost);

    if (post.postReplyTo != null) {
      for (final _post in posts) {
        if (_post.postId == post.postReplyTo) {
          for (final _postReply in _post.postReplies) {
            if (_postReply.postId == post.postId) {
              _postReply.post = post;
              return;
            }
          }
        }
      }
    }

    posts.add(post);
  });

  return posts;
}

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
  List<Attachment> attachments;

  @JsonKey(toJson: none)
  PostLinks links;

  @JsonKey(toJson: none)
  PostPermissions permissions;

  @JsonKey(toJson: none)
  List<PostReply> postReplies;
  bool postHasOtherReplies;
  int postReplyTo;
  int postReplyDepth;

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

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class PostReply {
  int from;
  String link;
  int postId;
  int postReplyCount;
  int postReplyTo;
  int to;

  @JsonKey(ignore: true)
  Post post;

  PostReply();
  factory PostReply.fromJson(Map<String, dynamic> json) =>
      _$PostReplyFromJson(json);
}

import 'package:json_annotation/json_annotation.dart';

import 'src/_.dart';
import 'attachment.dart';
import 'user.dart';

part 'post.g.dart';

List<Post> decodePostsAndTheirReplies(List jsonPosts, {int parentPostId}) {
  final posts = <Post>[];
  final postById = Map<int, Post>();

  jsonPosts.forEach((jsonPost) {
    final post = Post.fromJson(jsonPost);
    postById[post.postId] = post;

    if (post.postReplyTo == parentPostId) {
      posts.add(post);
      return;
    }

    if (post.postReplyTo == null) {
      print("Unexpected root post #${post.postId}");
      return;
    }

    if (!postById.containsKey(post.postReplyTo)) {
      print("Parent post #${post.postReplyTo} not found for #${post.postId}");
      return;
    }

    for (final _postReply in postById[post.postReplyTo].postReplies) {
      if (_postReply.postId == post.postId) {
        _postReply.post = post;
        return;
      }
    }

    print("Reply slot not found in #${post.postReplyTo} for #${post.postId}");
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
  bool posterHasVerifiedBadge;
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

  @JsonKey(toJson: none)
  UserRank posterRank;

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

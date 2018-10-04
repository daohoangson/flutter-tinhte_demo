import 'package:json_annotation/json_annotation.dart';

import '_.dart';
import 'thread_prefix.dart';
import 'post.dart';

part 'thread.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Thread {
  bool creatorHasVerifiedBadge;
  int creatorUserId;
  String creatorUsername;
  int forumId;
  Post firstPost;
  int threadCreateDate;
  final int threadId;
  bool threadIsDeleted;
  bool threadIsFollowed;
  bool threadIsPublished;
  bool threadIsSticky;
  int threadPostCount;
  Map<String, String> threadTags;
  String threadTitle;
  int threadUpdateDate;
  int threadViewCount;
  bool userIsIgnored;

  @JsonKey(toJson: none)
  ThreadLinks links;

  @JsonKey(toJson: none)
  ThreadPermissions permissions;

  @JsonKey(toJson: none)
  ThreadImage threadImage;

  @JsonKey(toJson: none)
  List<ThreadPrefix> threadPrefixes;
  
  @JsonKey(toJson: none)
  ThreadImage threadThumbnail;

  Thread(this.threadId);
  factory Thread.fromJson(Map<String, dynamic> json) => _$ThreadFromJson(json);
  Map<String, dynamic> toJson() => _$ThreadToJson(this);
}

@JsonSerializable(createToJson: false)
class ThreadImage {
  @JsonKey(name: "display_mode")
  final String displayMode;

  final int height;

  final String link;

  final int width;

  ThreadImage(this.displayMode, this.height, this.link, this.width);
  factory ThreadImage.fromJson(Map<String, dynamic> json) => _$ThreadImageFromJson(json);
}

@JsonSerializable(createToJson: false)
class ThreadLinks {
  String detail;

  @JsonKey(name: "first_post")
  String firstPost;

  @JsonKey(name: "first_poster")
  String firstPoster;

  @JsonKey(name: "first_poster_avatar")
  String firstPosterAvatar;

  String followers;

  String forum;

  String image;

  @JsonKey(name: "last_post")
  String lastPost;

  @JsonKey(name: "last_poster")
  String lastPoster;

  String permalink;

  String posts;
  
  ThreadLinks();
  factory ThreadLinks.fromJson(Map<String, dynamic> json) =>
      _$ThreadLinksFromJson(json);
}

@JsonSerializable(createToJson: false)
class ThreadPermissions {
  bool delete;

  bool edit;

  bool follow;

  bool post;

  @JsonKey(name: "upload_attachment")
  bool uploadAttachment;

  bool view;
  
  ThreadPermissions();
  factory ThreadPermissions.fromJson(Map<String, dynamic> json) =>
      _$ThreadPermissionsFromJson(json);
}

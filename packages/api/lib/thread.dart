import 'package:json_annotation/json_annotation.dart';

import 'node.dart';
import 'post.dart';
import 'thread_prefix.dart';

part 'thread.g.dart';

final _kThreadTitleEllipsisRegEx = RegExp(r'^(.+)\.\.\.$');
final _kThreadPostBodyImgBbCodeRegExp =
    RegExp(r'\[IMG\]([^[]+)\[/IMG\]', caseSensitive: false);

bool isThreadTitleRedundant(Thread thread, [Post firstPost]) {
  firstPost ??= thread?.firstPost;
  if (thread == null || firstPost == null) return false;

  final ellipsis = _kThreadTitleEllipsisRegEx.firstMatch(thread.threadTitle);
  if (ellipsis != null) {
    return firstPost.postBody?.startsWith(ellipsis.group(1)) == true;
  }

  return firstPost.postBody?.startsWith(thread.threadTitle) == true;
}

ThreadImage getThreadImage(Thread thread) {
  if (thread.threadImage != null) return thread.threadImage;

  if (thread.firstPost == null) return null;
  final post = thread.firstPost;

  if (post.attachments?.isNotEmpty == true) {
    for (final attachment in post.attachments) {
      if (attachment.links?.thumbnail?.isNotEmpty == true) {
        return ThreadImage(attachment.links.data)
          ..width = attachment.attachmentWidth
          ..height = attachment.attachmentHeight;
      }
    }
  }

  if (post.postBodyHtml?.isNotEmpty == true) {
    final match = _kThreadPostBodyImgBbCodeRegExp.firstMatch(post.postBody);
    if (match != null) return ThreadImage(match.group(1));
  }

  return null;
}

@JsonSerializable()
class Thread {
  bool creatorHasVerifiedBadge;
  int creatorUserId;
  String creatorUsername;
  int forumId;
  Post firstPost;
  int threadCreateDate;
  bool threadHasPoll;
  final int threadId;
  bool threadIsBookmark;
  bool threadIsDeleted;
  bool threadIsFollowed;
  bool threadIsNew;
  bool threadIsPublished;
  bool threadIsSticky;
  int threadPostCount;

  @JsonKey(fromJson: _threadTagsFromJson)
  Map<String, String> threadTags;

  String threadTitle;
  int threadUpdateDate;
  int threadViewCount;
  bool userIsIgnored;

  Forum forum;
  ThreadLinks links;
  ThreadPermissions permissions;
  ThreadImage threadImage;
  ThreadImage threadPrimaryImage;
  List<ThreadPrefix> threadPrefixes;
  ThreadImage threadThumbnail;

  Thread(this.threadId);
  factory Thread.fromJson(Map<String, dynamic> json) => _$ThreadFromJson(json);
}

@JsonSerializable()
class ThreadImage {
  String displayMode;

  int height;
  final String link;
  String mode;
  int size;
  int width;

  ThreadImage(this.link);
  factory ThreadImage.fromJson(Map<String, dynamic> json) =>
      _$ThreadImageFromJson(json);
}

@JsonSerializable()
class ThreadLinks {
  String detail;

  String firstPost;

  String firstPoster;

  String firstPosterAvatar;

  String followers;

  String forum;

  String image;

  String lastPost;

  String lastPoster;

  String permalink;

  String poll;

  String posts;

  String postsUnread;

  ThreadLinks();
  factory ThreadLinks.fromJson(Map<String, dynamic> json) =>
      _$ThreadLinksFromJson(json);
}

@JsonSerializable()
class ThreadPermissions {
  bool delete;

  bool edit;

  bool follow;

  bool post;

  bool uploadAttachment;

  bool view;

  ThreadPermissions();
  factory ThreadPermissions.fromJson(Map<String, dynamic> json) =>
      _$ThreadPermissionsFromJson(json);
}

Map<String, String> _threadTagsFromJson(json) {
  if (json == null) return null;

  // php returns empty json array if thread has no tags...
  if (json is List) return null;

  return Map<String, String>.from(json);
}

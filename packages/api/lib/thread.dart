import 'package:freezed_annotation/freezed_annotation.dart';

import 'node.dart';
import 'post.dart';
import 'thread_prefix.dart';

part 'thread.freezed.dart';
part 'thread.g.dart';

final _kThreadTitleEllipsisRegEx = RegExp(r'^(.+)\.\.\.$');
final _kThreadPostBodyImgBbCodeRegExp =
    RegExp(r'\[IMG\]([^[]+)\[/IMG\]', caseSensitive: false);

bool isThreadTitleRedundant(Thread thread, [Post? firstPost]) {
  final threadTitle = thread.threadTitle;
  final firstPostBody = (firstPost ?? thread.firstPost)?.postBody;
  if (threadTitle == null || firstPostBody == null) return false;

  final ellipsis = _kThreadTitleEllipsisRegEx.firstMatch(threadTitle);
  if (ellipsis != null) {
    return firstPostBody.startsWith(ellipsis[1]!);
  }

  return firstPostBody.startsWith(threadTitle);
}

ThreadImage? getThreadImage(Thread thread) {
  if (thread.threadImage != null) return thread.threadImage;

  final post = thread.firstPost;
  if (post == null) return null;

  if (post.attachments.isNotEmpty) {
    for (final attachment in post.attachments) {
      final dataLink = attachment.links?.data;
      if (dataLink == null) continue;

      final thumbnailLink = attachment.links?.thumbnail ?? '';
      if (thumbnailLink.isEmpty) continue;

      return ThreadImage(
        dataLink,
        width: attachment.attachmentWidth,
        height: attachment.attachmentHeight,
      );
    }
  }

  final postBody = post.postBody ?? '';
  if (postBody.isNotEmpty) {
    final matchedUrl =
        _kThreadPostBodyImgBbCodeRegExp.firstMatch(postBody)?.group(1);
    if (matchedUrl != null) return ThreadImage(matchedUrl);
  }

  return null;
}

@freezed
class Thread with _$Thread {
  const factory Thread(
    int threadId, {
    bool? creatorHasVerifiedBadge,
    int? creatorUserId,
    String? creatorUsername,
    int? forumId,
    Post? firstPost,
    int? threadCreateDate,
    bool? threadHasPoll,
    bool? threadIsBookmark,
    bool? threadIsDeleted,
    bool? threadIsFollowed,
    bool? threadIsNew,
    bool? threadIsPublished,
    bool? threadIsSticky,
    int? threadPostCount,
    @JsonKey(fromJson: _threadTagsFromJson) Map<String, String>? threadTags,
    String? threadTitle,
    int? threadUpdateDate,
    int? threadViewCount,
    bool? userIsIgnored,
    @JsonKey(fromJson: _forumFromJson, name: 'forum') Node? node,
    ThreadLinks? links,
    ThreadPermissions? permissions,
    ThreadImage? threadImage,
    ThreadImage? threadPrimaryImage,
    @Default([]) List<ThreadPrefix> threadPrefixes,
    ThreadImage? threadThumbnail,
  }) = _Thread;

  factory Thread.fromJson(Map<String, dynamic> json) => _$ThreadFromJson(json);

  const Thread._();

  Forum? get forum {
    final forum = node;
    return forum is Forum ? forum : null;
  }
}

@freezed
class ThreadImage with _$ThreadImage {
  const factory ThreadImage(
    String link, {
    String? displayMode,
    int? height,
    String? mode,
    int? size,
    int? width,
  }) = _ThreadImage;

  factory ThreadImage.fromJson(Map<String, dynamic> json) =>
      _$ThreadImageFromJson(json);
}

@freezed
class ThreadLinks with _$ThreadLinks {
  const factory ThreadLinks({
    String? detail,
    String? firstPost,
    String? firstPoster,
    String? firstPosterAvatar,
    String? followers,
    String? forum,
    String? image,
    String? lastPost,
    String? lastPoster,
    String? permalink,
    String? poll,
    String? posts,
    String? postsUnread,
  }) = _ThreadLinks;

  factory ThreadLinks.fromJson(Map<String, dynamic> json) =>
      _$ThreadLinksFromJson(json);
}

@freezed
class ThreadPermissions with _$ThreadPermissions {
  const factory ThreadPermissions({
    bool? delete,
    bool? edit,
    bool? follow,
    bool? post,
    bool? uploadAttachment,
    bool? view,
  }) = _ThreadPermissions;

  factory ThreadPermissions.fromJson(Map<String, dynamic> json) =>
      _$ThreadPermissionsFromJson(json);
}

Map<String, String>? _threadTagsFromJson(json) {
  if (json == null) return null;

  // php returns empty json array if thread has no tags...
  if (json is List) return null;

  return Map<String, String>.from(json);
}

Forum? _forumFromJson(json) {
  if (json is Map) {
    final node = Node.fromJson({
      ...json,
      'navigation_id': json['forum_id'],
      'navigation_type': 'forum',
    });
    if (node is Forum) return node;
  }

  return null;
}

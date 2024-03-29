import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'node.dart';
import 'poll.dart';
import 'post.dart';
import 'thread_prefix.dart';

part 'thread.freezed.dart';
part 'thread.g.dart';

final _kThreadTitleEllipsisRegEx = RegExp(r'^(.+)\.\.\.$');
final _kThreadPostBodyImgBbCodeRegExp =
    RegExp(r'\[IMG\]([^[]+)\[/IMG\]', caseSensitive: false);

class Thread extends ChangeNotifier implements _Thread, PollOwner {
  _ThreadInternal _;

  Poll? _poll;

  Thread.fromJson(Map<String, dynamic> json, {Forum? forum})
      : _ = _ThreadInternal.fromJson(json) {
    if (forum != null && _.node == null && forum.forumId == forumId) {
      _ = _.copyWith(node: forum);
    }
  }

  @Deprecated("Use setters instead of copyWith")
  @override
  // ignore: library_private_types_in_public_api
  _$$_ThreadCopyWith<_$_Thread> get copyWith => throw UnimplementedError();

  @override
  bool? get creatorHasVerifiedBadge => _.creatorHasVerifiedBadge;

  @override
  int? get creatorUserId => _.creatorUserId;

  @override
  String? get creatorUsername => _.creatorUsername;

  @override
  Post? get firstPost => _.firstPost;

  Forum? get forum {
    final forum = _.node;
    return forum is Forum ? forum : null;
  }

  @override
  int? get forumId => _.forumId;

  bool get isThreadTitleRedundant {
    final threadTitle = this.threadTitle;
    final firstPostBody = firstPost?.postBody;
    if (threadTitle == null || firstPostBody == null) return false;

    final ellipsis = _kThreadTitleEllipsisRegEx.firstMatch(threadTitle);
    if (ellipsis != null) {
      return firstPostBody.startsWith(ellipsis[1]!);
    }

    return firstPostBody.startsWith(threadTitle);
  }

  @override
  ThreadLinks? get links => _.links;

  @override
  Node? get node => _.node;

  List<Node>? _navigation;
  List<Node>? get navigation => _navigation;
  set navigation(List<Node>? v) {
    if (listEquals(v, _navigation)) return;

    _navigation = v;
    notifyListeners();
  }

  @override
  ThreadPermissions? get permissions => _.permissions;

  @override
  Poll? get poll => _poll;

  @override
  set poll(Poll? v) {
    if (v == _poll) return;

    _poll = v;
    notifyListeners();
  }

  @override
  String? get pollLink => links?.poll;

  @override
  int? get threadCreateDate => _.threadCreateDate;

  @override
  bool? get threadHasPoll => _.threadHasPoll;

  @override
  int get threadId => _.threadId;

  @override
  ThreadImage? get threadImage {
    if (_.threadImage != null) return _.threadImage;

    final post = _.firstPost;
    if (post == null) return null;

    if (post.attachments.isNotEmpty) {
      for (final attachment in post.attachments) {
        final dataLink = attachment.links?.data;
        if (!attachment.isImage || dataLink == null) continue;

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

  ThreadImage? get threadImageOriginal => _.threadImage;

  @override
  bool get threadIsBookmark => _.threadIsBookmark ?? false;

  set threadIsBookmark(bool v) {
    if (v == threadIsBookmark) return;

    _ = _.copyWith(threadIsBookmark: v);
    notifyListeners();
  }

  @override
  bool? get threadIsDeleted => _.threadIsDeleted;

  @override
  bool? get threadIsFollowed => _.threadIsFollowed;

  @override
  bool? get threadIsNew => _.threadIsNew;

  @override
  bool? get threadIsPublished => _.threadIsPublished;

  @override
  bool? get threadIsSticky => _.threadIsSticky;

  @override
  int? get threadPostCount => _.threadPostCount;

  @override
  List<ThreadPrefix> get threadPrefixes => _.threadPrefixes;

  @override
  ThreadImage? get threadPrimaryImage => _.threadPrimaryImage;

  @override
  Map<String, String>? get threadTags => _.threadTags;

  @override
  ThreadImage? get threadThumbnail => _.threadThumbnail;

  @override
  String? get threadTitle => _.threadTitle;

  @override
  int? get threadUpdateDate => _.threadUpdateDate;

  @override
  int? get threadViewCount => _.threadViewCount;

  @override
  Map<String, dynamic> toJson() => _.toJson();

  @override
  bool? get userIsIgnored => _.userIsIgnored;
}

@freezed
class _ThreadInternal with _$_ThreadInternal {
  const factory _ThreadInternal(
    int threadId,
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
    // ignore: invalid_annotation_target
    @JsonKey(fromJson: _threadTagsFromJson) Map<String, String>? threadTags,
    String? threadTitle,
    int? threadUpdateDate,
    int? threadViewCount,
    bool? userIsIgnored,
    // ignore: invalid_annotation_target
    @JsonKey(fromJson: _forumFromJson, name: 'forum') Node? node,
    ThreadLinks? links,
    ThreadPermissions? permissions,
    ThreadImage? threadImage,
    ThreadImage? threadPrimaryImage,
    // ignore: invalid_annotation_target
    @JsonKey(fromJson: threadPrefixesFromJson)
        List<ThreadPrefix> threadPrefixes,
    ThreadImage? threadThumbnail,
  ) = _Thread;

  factory _ThreadInternal.fromJson(Map<String, dynamic> json) =>
      _$_ThreadInternalFromJson(json);
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

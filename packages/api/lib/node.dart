import 'package:freezed_annotation/freezed_annotation.dart';

import 'thread.dart';

part 'node.freezed.dart';
part 'node.g.dart';

@Freezed(unionKey: 'navigation_type')
class Node with _$Node {
  const factory Node(
    int navigationId,
    String navigationType, {
    bool? hasSubElements,
    ElementLinks? links,
    int? navigationDepth,
    int? navigationParentId,
  }) = NavigationElement;

  const factory Node.category(
    int navigationId,
    String navigationType,
    // category
    int categoryId, {
    bool? hasSubElements,
    int? navigationDepth,
    int? navigationParentId,
    // category
    String? categoryDescription,
    String? categoryTitle,
    CategoryLinks? links,
    CategoryPermissions? permissions,
  }) = Category;

  const factory Node.forum(
    int navigationId,
    String navigationType,
    // forum
    int forumId, {
    bool? hasSubElements,
    int? navigationDepth,
    int? navigationParentId,
    // forum
    String? forumDescription,
    bool? forumIsFollowed,
    int? forumPostCount,
    @Default(const []) List<ThreadPrefix> forumPrefixes,
    int? forumThreadCount,
    String? forumTitle,
    ForumLinks? links,
    ForumPermissions? permissions,
    int? threadDefaultPrefixId,
    bool? threadPrefixIsRequired,
  }) = Forum;

  const factory Node.linkforum(
    int navigationId,
    String navigationType,
    //  link forum
    int linkId, {
    bool? hasSubElements,
    int? navigationDepth,
    int? navigationParentId,
    //  link forum
    String? linkDescription,
    String? linkTitle,
    LinkForumLinks? links,
  }) = LinkForum;

  factory Node.fromJson(Map<String, dynamic> json) => _$NodeFromJson(json);
}

@freezed
class CategoryLinks with _$CategoryLinks {
  const factory CategoryLinks({
    String? detail,
    String? permalink,

    // element links
    @JsonKey(name: 'sub-elements') String? subElements,
  }) = _CategoryLinks;

  factory CategoryLinks.fromJson(Map<String, dynamic> json) =>
      _$CategoryLinksFromJson(json);
}

@freezed
class CategoryPermissions with _$CategoryPermissions {
  const factory CategoryPermissions({
    bool? delete,
    bool? edit,
    bool? view,
  }) = _CategoryPermissions;

  factory CategoryPermissions.fromJson(Map<String, dynamic> json) =>
      _$CategoryPermissionsFromJson(json);
}

@freezed
class ElementLinks with _$ElementLinks {
  const factory ElementLinks({
    String? permalink,
    @JsonKey(name: 'sub-elements') String? subElements,
  }) = _ElementLinks;

  factory ElementLinks.fromJson(Map<String, dynamic> json) =>
      _$ElementLinksFromJson(json);
}

@freezed
class ForumLinks with _$ForumLinks {
  const factory ForumLinks({
    String? detail,
    String? followers,
    String? permalink,
    String? threads,
    // element links
    @JsonKey(name: 'sub-elements') String? subElements,
  }) = _ForumLinks;

  factory ForumLinks.fromJson(Map<String, dynamic> json) =>
      _$ForumLinksFromJson(json);
}

@freezed
class ForumPermissions with _$ForumPermissions {
  const factory ForumPermissions({
    bool? createThread,
    bool? delete,
    bool? edit,
    bool? follow,
    bool? tagThread,
    bool? uploadAttachment,
    bool? view,
  }) = _ForumPermissions;

  factory ForumPermissions.fromJson(Map<String, dynamic> json) =>
      _$ForumPermissionsFromJson(json);
}

@freezed
class LinkForumLinks with _$LinkForumLinks {
  const factory LinkForumLinks({
    String? target,

    // element links
    @JsonKey(name: 'sub-elements') String? subElements,
  }) = _LinkForumLinks;

  factory LinkForumLinks.fromJson(Map<String, dynamic> json) =>
      _$LinkForumLinksFromJson(json);
}

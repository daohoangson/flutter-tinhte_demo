import 'package:freezed_annotation/freezed_annotation.dart';

import 'thread_prefix.dart';

part 'node.freezed.dart';
part 'node.g.dart';

@Freezed(unionKey: 'navigation_type', fallbackUnion: 'default')
class Node with _$Node {
  const factory Node(
    int navigationId, {
    bool? hasSubElements,
    ElementLinks? links,
    int? navigationDepth,
    int? navigationParentId,
  }) = NavigationElement;

  const factory Node.category(
    int navigationId,
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
    // forum
    int forumId, {
    bool? hasSubElements,
    int? navigationDepth,
    int? navigationParentId,
    // forum
    String? forumDescription,
    bool? forumIsFollowed,
    int? forumPostCount,
    // ignore: invalid_annotation_target
    @JsonKey(fromJson: threadPrefixesFromJson)
    @Default([])
        List<ThreadPrefix> forumPrefixes,
    int? forumThreadCount,
    String? forumTitle,
    ForumLinks? links,
    ForumPermissions? permissions,
    int? threadDefaultPrefixId,
    bool? threadPrefixIsRequired,
  }) = Forum;

  const factory Node.linkforum(
    int navigationId,
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

  const Node._();

  String? get description => map(
        (_) => null,
        category: (_) => _.categoryDescription,
        forum: (_) => _.forumDescription,
        linkforum: (_) => _.linkDescription,
      );

  NodeLinks? get links => map(
        (_) => _.links,
        category: (_) => _.links,
        forum: (_) => _.links,
        linkforum: (_) => _.links,
      );

  String? get title => map(
        (_) => '#${_.navigationId}',
        category: (_) => _.categoryTitle,
        forum: (_) => _.forumTitle,
        linkforum: (_) => _.linkTitle,
      );
}

abstract class NodeLinks {
  String? get subElements;
}

@freezed
class CategoryLinks with _$CategoryLinks implements NodeLinks {
  const factory CategoryLinks({
    String? detail,
    String? permalink,
    // ignore: invalid_annotation_target
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
class ElementLinks with _$ElementLinks implements NodeLinks {
  const factory ElementLinks({
    String? permalink,

    // ignore: invalid_annotation_target
    @JsonKey(name: 'sub-elements') String? subElements,
  }) = _ElementLinks;

  factory ElementLinks.fromJson(Map<String, dynamic> json) =>
      _$ElementLinksFromJson(json);
}

@freezed
class ForumLinks with _$ForumLinks implements NodeLinks {
  const factory ForumLinks({
    String? detail,
    String? followers,
    String? permalink,
    String? threads,
    // ignore: invalid_annotation_target
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
class LinkForumLinks with _$LinkForumLinks implements NodeLinks {
  const factory LinkForumLinks({
    String? target,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'sub-elements') String? subElements,
  }) = _LinkForumLinks;

  factory LinkForumLinks.fromJson(Map<String, dynamic> json) =>
      _$LinkForumLinksFromJson(json);
}

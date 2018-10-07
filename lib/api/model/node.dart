import 'package:json_annotation/json_annotation.dart';

import '_.dart';
import 'thread_prefix.dart';

part 'node.g.dart';

abstract class Node {
  int get nodeId;
  String get title;
}

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class Category extends Node {
  String categoryDescription;
  final int categoryId;
  String categoryTitle;

  @JsonKey(toJson: none)
  CategoryLinks links;

  @JsonKey(toJson: none)
  CategoryPermissions permissions;

  @override
  int get nodeId => categoryId;

  @override
  String get title => categoryTitle;

  Category(this.categoryId);
  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);
}

@JsonSerializable(createToJson: false)
class CategoryLinks {
  String detail;
  String permalink;

  CategoryLinks();
  factory CategoryLinks.fromJson(Map<String, dynamic> json) => _$CategoryLinksFromJson(json);
}

@JsonSerializable(createToJson: false)
class CategoryPermissions {
  bool delete;
  bool edit;
  bool view;

  CategoryPermissions();
  factory CategoryPermissions.fromJson(Map<String, dynamic> json) => _$CategoryPermissionsFromJson(json);
}

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class Forum extends Node {
  String forumDescription;
  final int forumId;
  bool forumIsFollowed;
  int forumPostCount;
  List<ThreadPrefix> forumPrefixes;
  int forumThreadCount;
  String forumTitle;

  @JsonKey(toJson: none)
  ForumLinks links;

  @JsonKey(toJson: none)
  ForumPermissions permissions;

  int threadDefaultPrefixId;
  bool threadPrefixIsRequired;

  @override
  int get nodeId => forumId;

  @override
  String get title => forumTitle;

  Forum(this.forumId);
  factory Forum.fromJson(Map<String, dynamic> json) => _$ForumFromJson(json);
}

@JsonSerializable(createToJson: false)
class ForumLinks {
  String detail;
  String followers;
  String permalink;
  String threads;

  ForumLinks();
  factory ForumLinks.fromJson(Map<String, dynamic> json) => _$ForumLinksFromJson(json);
}

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class ForumPermissions {
  bool createThread;
  bool delete;
  bool edit;
  bool follow;
  bool tagThread;
  bool uploadAttachment;
  bool view;

  ForumPermissions();
  factory ForumPermissions.fromJson(Map<String, dynamic> json) => _$ForumPermissionsFromJson(json);
}
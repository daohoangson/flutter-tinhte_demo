import 'package:json_annotation/json_annotation.dart';

import 'node.dart';

part 'navigation.g.dart';

const NavigationTypeCategory = 'category';
const NavigationTypeForum = 'forum';
const NavigationTypeLinkForum = 'linkforum';

@JsonSerializable()
class Element {
  bool hasSubElements;

  ElementLinks links;

  final int navigationId;
  int navigationParentId;
  final String navigationType;

  @JsonKey(ignore: true)
  Node node;

  Element(this.navigationId, this.navigationType);

  factory Element.fromJson(Map<String, dynamic> json) {
    final e = _$ElementFromJson(json);

    switch (e.navigationType) {
      case NavigationTypeCategory:
        e.node = Category.fromJson(json);
        break;
      case NavigationTypeForum:
        e.node = Forum.fromJson(json);
        break;
      case NavigationTypeLinkForum:
        e.node = LinkForum.fromJson(json);
        break;
    }

    return e;
  }
}

@JsonSerializable()
class ElementLinks {
  String permalink;

  @JsonKey(name: 'sub-elements')
  String subElements;

  ElementLinks();
  factory ElementLinks.fromJson(Map<String, dynamic> json) =>
      _$ElementLinksFromJson(json);
}

@JsonSerializable()
class LinkForum extends Node {
  String linkDescription;
  final int linkId;
  String linkTitle;

  LinkForumLinks links;

  @override
  int get nodeId => linkId;

  @override
  String get title => linkTitle;

  LinkForum(this.linkId);
  factory LinkForum.fromJson(Map<String, dynamic> json) =>
      _$LinkForumFromJson(json);
}

@JsonSerializable()
class LinkForumLinks {
  String target;

  LinkForumLinks();
  factory LinkForumLinks.fromJson(Map<String, dynamic> json) =>
      _$LinkForumLinksFromJson(json);
}

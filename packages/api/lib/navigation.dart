import 'package:json_annotation/json_annotation.dart';

import 'node.dart';
import 'src/_.dart';

part 'navigation.g.dart';

const NavigationTypeCategory = 'category';
const NavigationTypeForum = 'forum';
const NavigationTypeLinkForum = 'linkforum';

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class Element {
  bool hasSubElements;

  @JsonKey(toJson: none)
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

@JsonSerializable(createToJson: false)
class ElementLinks {
  @JsonKey(name: 'sub-elements')
  String subElements;

  ElementLinks();
  factory ElementLinks.fromJson(Map<String, dynamic> json) =>
      _$ElementLinksFromJson(json);
}

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class LinkForum extends Node {
  String linkDescription;
  final int linkId;
  String linkTitle;

  @JsonKey(toJson: none)
  LinkForumLinks links;

  @override
  int get nodeId => linkId;

  @override
  String get title => linkTitle;

  LinkForum(this.linkId);
  factory LinkForum.fromJson(Map<String, dynamic> json) =>
      _$LinkForumFromJson(json);
}

@JsonSerializable(createToJson: false)
class LinkForumLinks {
  String target;

  LinkForumLinks();
  factory LinkForumLinks.fromJson(Map<String, dynamic> json) =>
      _$LinkForumLinksFromJson(json);
}

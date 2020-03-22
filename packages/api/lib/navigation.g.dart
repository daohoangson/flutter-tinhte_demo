// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'navigation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Element _$ElementFromJson(Map<String, dynamic> json) {
  return Element(
    json['navigation_id'] as int,
    json['navigation_type'] as String,
  )
    ..hasSubElements = json['has_sub_elements'] as bool
    ..links = json['links'] == null
        ? null
        : ElementLinks.fromJson(json['links'] as Map<String, dynamic>)
    ..navigationParentId = json['navigation_parent_id'] as int;
}

ElementLinks _$ElementLinksFromJson(Map<String, dynamic> json) {
  return ElementLinks()
    ..permalink = json['permalink'] as String
    ..subElements = json['sub-elements'] as String;
}

LinkForum _$LinkForumFromJson(Map<String, dynamic> json) {
  return LinkForum(
    json['link_id'] as int,
  )
    ..linkDescription = json['link_description'] as String
    ..linkTitle = json['link_title'] as String
    ..links = json['links'] == null
        ? null
        : LinkForumLinks.fromJson(json['links'] as Map<String, dynamic>);
}

LinkForumLinks _$LinkForumLinksFromJson(Map<String, dynamic> json) {
  return LinkForumLinks()..target = json['target'] as String;
}

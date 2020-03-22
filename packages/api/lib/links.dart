import 'package:json_annotation/json_annotation.dart';

part 'links.g.dart';

@JsonSerializable()
class Links {
  final String next;
  final int page;
  final int pages;
  final String prev;

  Links(this.next, this.page, this.pages, this.prev);
  factory Links.fromJson(Map<String, dynamic> json) => _$LinksFromJson(json);
}

import 'package:json_annotation/json_annotation.dart';

part 'thread_prefix.g.dart';

@JsonSerializable()
class ThreadPrefix {
  final int prefixId;
  final String prefixTitle;

  ThreadPrefix(this.prefixId, this.prefixTitle);
  factory ThreadPrefix.fromJson(Map<String, dynamic> json) =>
      _$ThreadPrefixFromJson(json);
}

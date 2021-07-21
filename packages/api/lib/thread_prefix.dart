import 'package:freezed_annotation/freezed_annotation.dart';

part 'thread_prefix.freezed.dart';
part 'thread_prefix.g.dart';

@freezed
class ThreadPrefix with _$ThreadPrefix {
  const factory ThreadPrefix(
    int prefixId,
    String prefixTitle,
  ) = _ThreadPrefix;

  factory ThreadPrefix.fromJson(Map<String, dynamic> json) =>
      _$ThreadPrefixFromJson(json);
}

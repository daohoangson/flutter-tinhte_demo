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

@freezed
class PrefixGroup with _$PrefixGroup {
  const factory PrefixGroup(
    String groupTitle,
    List<ThreadPrefix> groupPrefixes,
  ) = _PrefixGroup;

  factory PrefixGroup.fromJson(Map<String, dynamic> json) =>
      _$PrefixGroupFromJson(json);
}

List<ThreadPrefix> threadPrefixesFromJson(json) {
  if (json is! List || json.isEmpty) return const [];
  final first = json.first;
  if (first is! Map) return const [];

  final groupTitle = first['group_title'];
  if (groupTitle != null) {
    final groups = json.map((j) => PrefixGroup.fromJson(j));
    return groups.fold<List<ThreadPrefix>>(
        const [],
        (previousValue, element) =>
            [...previousValue, ...element.groupPrefixes]);
  }

  return json.map((j) => ThreadPrefix.fromJson(j)).toList(growable: false);
}

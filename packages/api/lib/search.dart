import 'package:json_annotation/json_annotation.dart';

import 'thread.dart';
import 'x_content_list.dart';

part 'search.g.dart';

@JsonSerializable()
class SearchResult<T> {
  final String contentType;
  final int contentId;

  ContentListItem listItem;

  @JsonKey(ignore: true)
  T content;

  SearchResult(this.contentType, this.contentId);
  factory SearchResult.fromJson(Map<String, dynamic> json) {
    final result = _$SearchResultFromJson<T>(json);

    switch (result.contentType) {
      case 'thread':
        final thread = Thread.fromJson(json);
        if (thread is T) {
          result.content = thread as T;
        } else {
          return null;
        }
        break;
    }

    return result;
  }
}

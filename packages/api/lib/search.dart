import 'thread.dart';
import 'x_content_list.dart';

class SearchResult<T> {
  final String contentType;
  final int contentId;

  final T? content;
  final ContentListItem? listItem;

  SearchResult(
    this.contentType,
    this.contentId, {
    this.content,
    this.listItem,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    final contentType = json['content_type']! as String;
    final contentId = json['content_id']! as int;
    T? content;

    switch (contentType) {
      case 'thread':
        final thread = Thread.fromJson(json);
        if (thread is T) {
          content = thread as T;
        }
        break;
    }

    return SearchResult(
      contentType,
      contentId,
      content: content,
      listItem: json.containsKey('list_item')
          ? ContentListItem.fromJson(json['list_item'])
          : null,
    );
  }
}

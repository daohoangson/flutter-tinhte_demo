import 'thread.dart';
import 'x_content_list.dart';
import 'x_user_feed.dart';

class SearchResult<T> {
  final String contentType;
  final int contentId;

  final T? content;
  final UserFeedData? feedData;
  final ContentListItem? listItem;

  SearchResult(
    this.contentType,
    this.contentId, {
    this.content,
    this.feedData,
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
      feedData: json.containsKey('feed_data')
          ? UserFeedData.fromJson(json['feed_data'])
          : null,
      listItem: json.containsKey('list_item')
          ? ContentListItem.fromJson(json['list_item'])
          : null,
    );
  }
}

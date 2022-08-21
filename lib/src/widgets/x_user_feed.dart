import 'package:flutter/material.dart';
import 'package:the_api/search.dart';
import 'package:the_api/thread.dart';
import 'package:the_app/src/widgets/super_list.dart';
import 'package:the_app/src/widgets/threads.dart';

class UserFeedItems extends StatelessWidget {
  @override
  Widget build(BuildContext _) => SuperListView<SearchResult>(
        fetchOnSuccess: _fetchOnSuccess,
        fetchPathInitial: 'users/me/feed',
        itemBuilder: (_, __, item) =>
            _buildContent(item) ?? const SizedBox.shrink(),
      );

  Widget? _buildContent(SearchResult item) {
    if (item.content is Thread) {
      final thread = item.content as Thread;
      if (thread.firstPost != null)
        return ThreadWidget(thread, feedData: item.feedData);
    }

    return null;
  }

  void _fetchOnSuccess(Map json, FetchContext<SearchResult> fc) {
    if (!json.containsKey('data')) return;

    final list = json['data'] as List;
    for (final json in list) {
      final searchResult = SearchResult.fromJson(json);
      if (searchResult.content == null || searchResult.feedData == null)
        continue;

      fc.items.add(searchResult);
    }
  }
}

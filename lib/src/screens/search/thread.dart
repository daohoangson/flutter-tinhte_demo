import 'package:flutter/material.dart';

import '../../widgets/threads.dart';
import '../../api.dart';

class ThreadSearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) => [
        IconButton(
          icon: Icon(Icons.clear),
          onPressed: () => query = '',
        )
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) => ThreadsWidget(
        apiMethod: apiPost,
        path: "search/threads?q=${Uri.encodeQueryComponent(query)}",
        threadsKey: 'data',
      );

  @override
  Widget buildSuggestions(BuildContext context) => SizedBox.shrink();
}

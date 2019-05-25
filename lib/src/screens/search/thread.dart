import 'dart:async';

import 'package:flutter/material.dart';

import '../../widgets/threads.dart';
import '../../api.dart';

class ThreadSearchDelegate extends SearchDelegate {
  _ApiQuery _apiQuery;

  @override
  List<Widget> buildActions(BuildContext context) => [
        IconButton(
          icon: Icon(Icons.clear),
          onPressed: () => query = '',
        )
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        icon: BackButtonIcon(),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) {
    _apiQuery = (query.isEmpty || _apiQuery?.query == query)
        ? _apiQuery
        : _ApiQuery(context, query, this);

    return _buildResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) =>
      _apiQuery == null ? SizedBox.shrink() : _buildResults(context);

  _buildResults(BuildContext context) => FutureBuilder<Map>(
        future: _apiQuery.future,
        builder: (context, snapshot) => snapshot.hasData
            ? ThreadsWidget(
                initialJson: snapshot.data,
                threadsKey: 'data',
              )
            : const Center(
                child: CircularProgressIndicator(),
              ),
      );
}

class _ApiQuery extends ApiCaller {
  final BuildContext context;
  final String query;

  final _completer = Completer<Map>();
  final ThreadSearchDelegate _delegate;

  _ApiQuery(this.context, this.query, this._delegate) {
    apiPost(
      this,
      "search/threads?q=${Uri.encodeQueryComponent(query)}",
      onSuccess: (jsonMap) => _completer.complete(jsonMap),
    );
  }

  @override
  bool get canReceiveCallback => _delegate._apiQuery == this;

  Future<Map> get future => _completer.future;
}

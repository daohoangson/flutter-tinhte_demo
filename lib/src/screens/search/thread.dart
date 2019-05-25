import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tinhte_api/node.dart';
import 'package:tinhte_api/user.dart';

import '../../widgets/threads.dart';
import '../../api.dart';

class ThreadSearchDelegate extends SearchDelegate {
  final Forum forum;
  final User user;

  _ApiQuery _apiQuery;

  ThreadSearchDelegate({
    this.forum,
    this.user,
  });

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
      _apiQuery != null ? _buildResults(context) : _buildExplain();

  Widget _buildExplain() {
    final sb = StringBuffer();
    if (query.isEmpty) {
      sb.write("Enter something to search");
    } else {
      sb.write("Submit to search for '$query'");
    }

    if (forum != null) {
      sb.write(" in forum '${forum.title}'");
    }
    if (user != null) {
      sb.write(" by user '${user.username}'");
    }

    sb.write(query.isEmpty ? '...' : '.');

    return Padding(
      child: Text(sb.toString()),
      padding: const EdgeInsets.all(10),
    );
  }

  Widget _buildResults(BuildContext context) => FutureBuilder<Map>(
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
      "search/threads?q=${Uri.encodeQueryComponent(query)}"
      "&forum_id=${_delegate.forum?.forumId ?? 0}"
      "&user_id=${_delegate.user?.userId ?? 0}",
      onSuccess: (jsonMap) => _completer.complete(jsonMap),
    );
  }

  @override
  bool get canReceiveCallback => _delegate._apiQuery == this;

  Future<Map> get future => _completer.future;
}

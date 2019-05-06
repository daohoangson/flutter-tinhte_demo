import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tinhte_api/thread.dart';

import 'api.dart';
import 'screens/thread_view.dart';

final _postIdFragmentRegExp = RegExp(r'#post-(\d+)$');

Future<bool> parseLink(State state, String link) {
  var cancelled = false;
  final completer = Completer<bool>();
  var parsed = false;

  showDialog(
    context: state.context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
          content: Text('Just a moment...'),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                cancelled = true;
                Navigator.of(context).pop();
              },
            )
          ],
        ),
  );

  apiGet(
    state,
    'tools/parse-link?link=${Uri.encodeQueryComponent(link)}',
    onSuccess: (json) {
      if (cancelled) return;
      if (json.containsKey('thread') && json.containsKey('posts')) {
        parsed = _parseThread(state, link, json);
      }
    },
    onError: (error) {
      debugPrint("$error");
    },
    onComplete: () {
      if (!cancelled) Navigator.of(state.context, rootNavigator: true).pop();
      completer.complete(parsed);
    },
  );

  return completer.future;
}

bool _parseThread(State state, String link, Map<dynamic, dynamic> json) {
  final Map<dynamic, dynamic> jsonThread = json['thread'];
  final thread = Thread.fromJson(jsonThread);
  if (thread.threadId == null) return false;

  int scrollToPostId;
  final postIdFragment = _postIdFragmentRegExp.firstMatch(link);
  if (postIdFragment != null) {
    scrollToPostId = int.tryParse(postIdFragment[1]);
  }

  pushThreadViewScreen(
    state.context,
    thread,
    json: json,
    scrollToPostId: scrollToPostId,
  );
  return true;
}

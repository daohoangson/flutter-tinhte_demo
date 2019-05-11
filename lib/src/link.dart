import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tinhte_api/feature_page.dart';
import 'package:tinhte_api/tag.dart';
import 'package:tinhte_api/thread.dart';
import 'package:url_launcher/url_launcher.dart';

import 'api.dart';
import 'config.dart';
import 'screens/fp_view.dart';
import 'screens/tag_view.dart';
import 'screens/thread_view.dart';

void launchLink(State state, String link) async {
  if (link.startsWith(configSiteRoot)) {
    final parsed = await parseLink(state, link);
    if (parsed) return;

    final data = ApiData.of(state.context);
    if (data.hasToken) {
      link = "$configApiRoot?tools/login&oauth_token=${data.token.accessToken}&"
          "redirect_uri=${Uri.encodeQueryComponent(link)}";
    }
  }

  if (!await canLaunch(link)) return;

  launch(link);
}

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

      if (json.containsKey('tag') && json.containsKey('tagged')) {
        parsed = _parseTag(state, json);
        return;
      }

      if (json.containsKey('thread') && json.containsKey('posts')) {
        parsed = _parseThread(state, json);
        return;
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

bool _parseTag(State state, Map json) {
  final Map jsonTag = json['tag'];
  final tag = Tag.fromJson(jsonTag);
  if (tag.tagId == null) return false;

  if (json.containsKey('feature_page')) {
    final fp = FeaturePage.fromJson(json['feature_page']);
    if (fp.id != null) {
      pushFpViewScreen(state.context, fp);
      return true;
    }
  }

  pushTagViewScreen(state.context, tag, json: json);
  return true;
}

bool _parseThread(State state, Map json) {
  final Map jsonThread = json['thread'];
  final thread = Thread.fromJson(jsonThread);
  if (thread.threadId == null) return false;

  pushThreadViewScreen(state.context, thread, json: json);
  return true;
}

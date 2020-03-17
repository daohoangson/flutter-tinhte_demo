import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tinhte_api/feature_page.dart';
import 'package:tinhte_api/tag.dart';
import 'package:tinhte_api/thread.dart';
import 'package:tinhte_api/user.dart';
import 'package:tinhte_demo/src/api.dart';
import 'package:tinhte_demo/src/config.dart';
import 'package:tinhte_demo/src/screens/fp_view.dart';
import 'package:tinhte_demo/src/screens/member_view.dart';
import 'package:tinhte_demo/src/screens/tag_view.dart';
import 'package:tinhte_demo/src/screens/thread_view.dart';
import 'package:url_launcher/url_launcher.dart';

void launchLink(BuildContext context, String link) async {
  // automatically cancel launching for CHR links
  // TODO: reconsider when https://github.com/daohoangson/flutter_widget_from_html/pull/116 is merged
  if (link.contains('misc/api-chr')) return;

  if (link.startsWith(configSiteRoot)) {
    final parsed = await parseLink(context: context, link: link);
    if (parsed) return;

    final apiAuth = ApiAuth.of(context, listen: false);
    if (apiAuth.hasToken) {
      link = "$configApiRoot?tools/login"
          "&oauth_token=${apiAuth.token.accessToken}"
          "&redirect_uri=${Uri.encodeQueryComponent(link)}";
    }
  }

  if (!await canLaunch(link)) return;

  launch(link);
}

void launchMemberView(BuildContext context, int userId) =>
    launchLink(context, "$configSiteRoot/members/$userId/");

Future<bool> parseLink({
  BuildContext context,
  String link,
  NavigatorState rootNavigator,
  String path,
}) {
  assert((context == null) != (rootNavigator == null));
  assert((link == null) != (path == null));
  final navigator = rootNavigator ?? Navigator.of(context);
  var cancelled = false;
  final completer = Completer<bool>();
  var parsed = false;
  var userCancelled = false;

  navigator.push(_DialogRoute((_) => AlertDialog(
        content: Text('Just a moment...'),
        actions: <Widget>[
          FlatButton(
            child: Text('Cancel'),
            onPressed: () {
              cancelled = true;
              userCancelled = true;
              navigator.pop();
            },
          )
        ],
      )));

  final cancelDialog = () {
    if (cancelled) return;

    navigator.pop();
    cancelled = true;
  };

  apiGet(
    ApiCaller.stateless(context ?? rootNavigator.context),
    path ?? 'tools/parse-link?link=${Uri.encodeQueryComponent(link)}',
    onSuccess: (json) {
      if (cancelled) return;

      Route route;
      if (json.containsKey('tag') && json.containsKey('tagged')) {
        route = _parseTag(json);
      } else if (json.containsKey('thread') && json.containsKey('posts')) {
        route = _parseThread(json);
      } else if (json.containsKey('user')) {
        route = _parseUser(json);
      }
      if (cancelled) return;

      if (route != null) {
        parsed = true;
        cancelDialog();
        navigator.push(route);
      }
    },
    onError: (error) => debugPrint("$error"),
    onComplete: () {
      cancelDialog();
      completer.complete(parsed || userCancelled);
    },
  );

  return completer.future;
}

Route _parseTag(Map json) {
  final Map jsonTag = json['tag'];
  final tag = Tag.fromJson(jsonTag);
  if (tag.tagId == null) return null;

  if (json.containsKey('feature_page')) {
    final fp = FeaturePage.fromJson(json['feature_page']);
    if (fp.id != null) {
      return MaterialPageRoute(builder: (_) => FpViewScreen(fp));
    }
  }

  return MaterialPageRoute(
    builder: (_) => TagViewScreen(tag, initialJson: json),
  );
}

Route _parseThread(Map json) {
  final Map jsonThread = json['thread'];
  final thread = Thread.fromJson(jsonThread);
  if (thread.threadId == null) return null;

  return MaterialPageRoute(
    builder: (_) => ThreadViewScreen(thread, initialJson: json),
  );
}

Route _parseUser(Map json) {
  final Map jsonUser = json['user'];
  final user = User.fromJson(jsonUser);
  if (user.userId == null) return null;

  return MaterialPageRoute(
    builder: (_) => MemberViewScreen(user),
  );
}

class _DialogRoute extends PopupRoute {
  final WidgetBuilder builder;

  _DialogRoute(this.builder);

  @override
  bool get barrierDismissible => false;

  @override
  String get barrierLabel => '';

  @override
  Color get barrierColor => Colors.black54;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation) =>
      SafeArea(child: Builder(builder: builder));

  @override
  Duration get transitionDuration => Duration.zero;
}

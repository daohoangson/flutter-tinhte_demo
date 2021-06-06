import 'dart:async';
import 'package:flutter/material.dart';
import 'package:the_api/feature_page.dart';
import 'package:the_api/tag.dart';
import 'package:the_api/thread.dart';
import 'package:the_api/user.dart';
import 'package:the_app/src/api.dart';
import 'package:the_app/src/config.dart';
import 'package:the_app/src/intl.dart';
import 'package:the_app/src/screens/fp_view.dart';
import 'package:the_app/src/screens/member_view.dart';
import 'package:the_app/src/screens/tag_view.dart';
import 'package:the_app/src/screens/thread_view.dart';
import 'package:url_launcher/url_launcher.dart';

String buildToolsParseLinkPath(String link) =>
    "tools/parse-link?link=${Uri.encodeQueryComponent(link)}";

void launchLink(
  BuildContext context,
  String link, {
  bool forceWebView = false,
}) async {
  // automatically cancel launching for CHR links
  // TODO: reconsider when https://github.com/daohoangson/flutter_widget_from_html/pull/116 is merged
  if (link.contains('misc/api-chr')) return;

  if (link.startsWith(config.siteRoot)) {
    final path = buildToolsParseLinkPath(link);
    if (!forceWebView) {
      final parsed = await parsePath(path, context: context);
      if (parsed) return;

      // this is our link, we tried to parse it and failed
      // let's open it via webview
      forceWebView = true;
    }

    final apiAuth = ApiAuth.of(context, listen: false);
    if (apiAuth.hasToken) {
      link = "${config.apiRoot}?tools/login"
          "&oauth_token=${apiAuth.token.accessToken}"
          "&redirect_uri=${Uri.encodeQueryComponent(link)}";
    }
  }

  if (!await canLaunch(link)) return;

  launch(
    link,
    forceSafariVC: forceWebView,
    forceWebView: forceWebView,
    enableDomStorage: true,
    enableJavaScript: true,
  );
}

void launchMemberView(BuildContext context, int userId) =>
    launchLink(context, "${config.siteRoot}/members/$userId/");

Future<bool> parsePath(
  String path, {
  BuildContext context,
  Widget defaultWidget,
  NavigatorState rootNavigator,
}) {
  assert(path != null);
  assert((context == null) != (rootNavigator == null));
  final navigator = rootNavigator ?? Navigator.of(context);
  if (context == null) context = navigator.context;
  var cancelled = false;

  navigator.push(_DialogRoute((_) => AlertDialog(
        content: Text(l(context).justAMomentEllipsis),
        actions: <Widget>[
          TextButton(
            child: Text(lm(context).cancelButtonLabel),
            onPressed: () {
              cancelled = true;
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

  return buildWidget(
    ApiCaller.stateless(context),
    path,
    defaultWidget: defaultWidget,
  ).then<bool>(
    (widget) {
      if (cancelled || widget == null) return false;

      cancelDialog();
      navigator.push(MaterialPageRoute(builder: (_) => widget));
      return true;
    },
    onError: (error) {
      print(error);
      return false;
    },
  ).whenComplete(() => cancelDialog());
}

Future<Widget> buildWidget(
  ApiCaller caller,
  String path, {
  Widget defaultWidget,
}) {
  final completer = Completer<Widget>();

  apiGet(
    caller,
    path,
    onSuccess: (json) {
      Widget widget = defaultWidget;
      if (json.containsKey('tag') && json.containsKey('tagged')) {
        widget = _parseTag(json);
      } else if (json.containsKey('thread') && json.containsKey('posts')) {
        widget = _parseThread(json);
      } else if (json.containsKey('user')) {
        widget = _parseUser(json);
      }

      completer.complete(widget);
    },
    onError: (error) => completer.completeError(error),
  );

  return completer.future;
}

Widget _parseTag(Map json) {
  final Map jsonTag = json['tag'];
  final tag = Tag.fromJson(jsonTag);
  if (tag.tagId == null) return null;

  if (json.containsKey('feature_page')) {
    final fp = FeaturePage.fromJson(json['feature_page']);
    if (getFeaturePageId(fp) != null) return FpViewScreen(fp);
  }

  return TagViewScreen(tag, initialJson: json);
}

Widget _parseThread(Map json) {
  final Map jsonThread = json['thread'];
  final thread = Thread.fromJson(jsonThread);
  if (thread.threadId == null) return null;

  return ThreadViewScreen(thread, initialJson: json);
}

Widget _parseUser(Map json) {
  final Map jsonUser = json['user'];
  final user = User.fromJson(jsonUser);
  if (user.userId == null) return null;

  return MemberViewScreen(user);
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

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
import 'package:the_app/src/screens/home.dart';
import 'package:the_app/src/screens/member_view.dart';
import 'package:the_app/src/screens/tag_view.dart';
import 'package:the_app/src/screens/thread_view.dart';
import 'package:url_launcher/url_launcher.dart';

String buildToolsParseLinkPath(String link) =>
    "tools/parse-link?link=${Uri.encodeQueryComponent(link)}";

Future<bool> launchLink(
  BuildContext context,
  String link, {
  bool forceWebView = false,
}) async {
  final apiAuth = ApiAuth.of(context, listen: false);

  if (link.startsWith(config.siteRoot)) {
    final path = buildToolsParseLinkPath(link);
    if (!forceWebView) {
      final parsed = await parsePath(path, context: context);
      if (parsed) return true;

      // this is our link, we tried to parse it and failed
      // force web view to avoid universal link loop
      forceWebView = true;
    }

    final token = apiAuth.token;
    if (token != null) {
      link = "${config.apiRoot}?tools/login"
          "&oauth_token=${token.accessToken}"
          "&redirect_uri=${Uri.encodeQueryComponent(link)}";
    }
  }

  final uri = Uri.tryParse(link);
  if (uri == null) return false;
  if (!await canLaunchUrl(uri)) return false;

  return launchUrl(
    uri,
    mode: forceWebView ? LaunchMode.inAppWebView : LaunchMode.platformDefault,
    webViewConfiguration: const WebViewConfiguration(
      enableDomStorage: true,
      enableJavaScript: true,
    ),
  );
}

void launchMemberView(BuildContext context, int userId) =>
    launchLink(context, "${config.siteRoot}/members/$userId/");

Future<bool> parsePath(
  String path, {
  BuildContext? context,
  Widget? defaultWidget,
  NavigatorState? rootNavigator,
}) {
  assert((context == null) != (rootNavigator == null));
  final navigator = rootNavigator ?? Navigator.of(context!);
  final ctx = context ??= navigator.context;

  var cancelled = false;

  navigator.push(_DialogRoute((_) => AlertDialog(
        content: Text(l(ctx).justAMomentEllipsis),
        actions: <Widget>[
          TextButton(
            child: Text(lm(ctx).cancelButtonLabel),
            onPressed: () {
              cancelled = true;
              navigator.pop();
            },
          )
        ],
      )));

  cancelDialog() {
    if (cancelled) return;

    navigator.pop();
    cancelled = true;
  }

  return buildWidget(
    ApiCaller.stateless(context),
    path,
    defaultWidget: defaultWidget,
  ).then<bool>(
    (widget) {
      if (cancelled || widget == null) return false;

      cancelDialog();
      if (widget is HomeScreen) {
        // special handling for home screen
        navigator.popUntil((route) => route.isFirst);
      } else {
        navigator.push(MaterialPageRoute(builder: (_) => widget));
      }
      return true;
    },
    onError: (_) => false,
  ).whenComplete(() => cancelDialog());
}

Future<Widget?> buildWidget(
  ApiCaller caller,
  String path, {
  Widget? defaultWidget,
}) {
  final completer = Completer<Widget>();

  apiGet(
    caller,
    path,
    onSuccess: (json) {
      Widget? widget;

      if (json.containsKey('tag') && json.containsKey('tagged')) {
        widget = _parseTag(json);
      } else if (json.containsKey('thread') && json.containsKey('posts')) {
        widget = _parseThread(json);
      } else if (json.containsKey('user')) {
        widget = _parseUser(json);
      }

      if (widget == null && json.containsKey('link')) {
        final link = json['link'];
        if (link is String) {
          final uri = Uri.tryParse(link);
          if (uri != null) {
            switch (uri.path) {
              case '':
              case '/':
                widget = HomeScreen();
                break;
            }
          }
        }
      }

      completer.complete(widget ?? defaultWidget);
    },
    onError: (error) => completer.completeError(error),
  );

  return completer.future;
}

Widget _parseTag(Map json) {
  final tagValue = json['tag'];
  final tagJson =
      tagValue is Map<String, dynamic> ? tagValue : const <String, dynamic>{};
  final tag = Tag.fromJson(tagJson);

  if (json.containsKey('feature_page')) {
    final fp = FeaturePage.fromJson(json['feature_page']);
    if (fp.id != null) return FpViewScreen(fp);
  }

  return TagViewScreen(tag, initialJson: json);
}

Widget _parseThread(Map json) {
  final threadValue = json['thread'];
  final threadJson = threadValue is Map<String, dynamic>
      ? threadValue
      : const <String, dynamic>{};
  final thread = Thread.fromJson(threadJson);

  return ThreadViewScreen(thread, initialJson: json);
}

Widget _parseUser(Map json) {
  final userValue = json['user'];
  final userJson =
      userValue is Map<String, dynamic> ? userValue : const <String, dynamic>{};
  final user = User.fromJson(userJson);

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

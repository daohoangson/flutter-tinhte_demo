import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:the_api/notification.dart' as api;
import 'package:the_api/oauth_token.dart';
import 'package:the_api/user.dart';
import 'package:the_app/src/abstracts/cached_network_image.dart' as cached;
import 'package:the_app/src/widgets/html.dart';
import 'package:the_app/src/widgets/super_list.dart';
import 'package:the_app/src/api.dart';
import 'package:the_app/src/config.dart';
import 'package:the_app/src/intl.dart';
import 'package:the_app/src/push_notification.dart';

int _subscribedUserId = 0;

class NotificationsWidget extends StatefulWidget {
  const NotificationsWidget({super.key});

  @override
  State<NotificationsWidget> createState() => _NotificationsState();
}

class _NotificationsState extends State<NotificationsWidget> {
  final _slsKey = GlobalKey<SuperListState<api.Notification>>();

  late final StreamSubscription subscription;

  @override
  initState() {
    super.initState();
    subscription = listenToNotification(_onNotificationData);
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Consumer2<PushNotificationToken, User>(
        builder: (context, pnt, user, __) {
          if (user.userId > 0 && user.userId != _subscribedUserId) {
            final fcmToken = pnt.value;
            final token = ApiAuth.of(context, listen: false).token;
            if (fcmToken != null && token != null) {
              _subscribe(context, fcmToken, token, user);
            }
          }

          return SuperListView<api.Notification>(
            fetchPathInitial: 'notifications',
            fetchOnSuccess: _fetchOnSuccess,
            itemBuilder: (context, __, n) => _buildRow(context, n),
            key: _slsKey,
          );
        },
      );

  Widget _buildRow(BuildContext context, api.Notification n) => Card(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 5, 0, 0),
              child: _buildAvatar(n),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildHtmlWidget(context, n),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 0, 5),
                    child: _buildInfo(context, n),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildAvatar(api.Notification n) {
    final avatar = n.links?.creatorAvatar;
    return CircleAvatar(
      backgroundImage: avatar != null ? cached.image(avatar) : null,
    );
  }

  Widget _buildHtmlWidget(BuildContext context, api.Notification n) {
    final html = n.notificationHtml ?? '';
    if (html.isEmpty) return const SizedBox.shrink();

    final w =
        n.notificationIsUnread == true ? FontWeight.bold : FontWeight.normal;
    final s = DefaultTextStyle.of(context).style.copyWith(fontWeight: w);

    return TinhteHtmlWidget(html, textStyle: s);
  }

  Widget _buildInfo(BuildContext context, api.Notification n) {
    final style = Theme.of(context).textTheme.bodySmall;
    final timestamp = Text(
      formatTimestamp(context, n.notificationCreateDate),
      style: style,
    );

    final icon = _getContentActionIcon(n.contentAction);
    if (icon == null) return timestamp;

    return Wrap(
      spacing: 5,
      children: <Widget>[
        Icon(icon, color: style?.color, size: style?.fontSize),
        timestamp,
      ],
    );
  }

  void _fetchOnSuccess(Map json, FetchContext<api.Notification> fc) {
    if (json.containsKey('notifications')) {
      final list = json['notifications'] as List;
      fc.items.addAll(list.map((j) => api.Notification.fromJson(j)));
    }

    if (fc.id == FetchContextId.fetchInitial) {
      apiPost(ApiCaller.stateless(fc.state.context), 'notifications/read');
    }
  }

  void _onNotificationData(int newId) {
    final apiAuth = ApiAuth.of(context, listen: false);
    final token = apiAuth.token;
    if (token == null) return;

    apiAuth.api
        .getJson("notifications?oauth_token=${token.accessToken}")
        .then((json) {
      final listValue = json['notifications'];
      final list = listValue is List ? listValue : [];
      final filtered = list.where((j) {
        if (j is Map) {
          return j['notification_id'] == newId;
        } else {
          return false;
        }
      });
      if (filtered.length != 1) return;

      final notification = api.Notification.fromJson(filtered.first);
      _slsKey.currentState?.itemsInsert(0, notification);
    });
  }

  void _subscribe(
    BuildContext context,
    String fcmToken,
    OauthToken token,
    User user,
  ) async {
    if (fcmToken.isEmpty) return;

    final url = "${config.pushServer}/subscribe";
    final hubTopic = "user_notification_${user.userId}";
    final response = await http.post(
      Uri.parse(url),
      body: {
        'extra_params[oauth_token]': token.accessToken,
        'hub.topic': hubTopic,
        'registration_token': fcmToken,
      },
    );

    if (response.statusCode == 202) {
      debugPrint("Subscribed $fcmToken at $url for $hubTopic...");
      _subscribedUserId = user.userId;
    } else {
      debugPrint("Failed subscribing $fcmToken: "
          "status=${response.statusCode}, body=${response.body}");
    }
  }

  static IconData? _getContentActionIcon(String? contentAction) {
    switch (contentAction) {
      case 'like':
        return FontAwesomeIcons.solidHeart;
      case 'quote':
        return FontAwesomeIcons.quoteRight;
      case 'tinhte_xentag_tag_watch':
        return FontAwesomeIcons.tag;
    }

    return null;
  }
}

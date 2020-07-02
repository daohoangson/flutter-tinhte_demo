import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:tinhte_api/notification.dart' as api;
import 'package:tinhte_api/oauth_token.dart';
import 'package:tinhte_api/user.dart';
import 'package:tinhte_demo/src/widgets/html.dart';
import 'package:tinhte_demo/src/widgets/super_list.dart';
import 'package:tinhte_demo/src/api.dart';
import 'package:tinhte_demo/src/config.dart';
import 'package:tinhte_demo/src/intl.dart';
import 'package:tinhte_demo/src/push_notification.dart';

int _subscribedUserId = 0;

class NotificationsWidget extends StatefulWidget {
  NotificationsWidget({Key key}) : super(key: key);

  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<NotificationsWidget> {
  final _slsKey = GlobalKey<SuperListState<api.Notification>>();

  StreamSubscription subscription;

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
  Widget build(BuildContext _) => Consumer2<PushNotificationToken, User>(
        builder: (context, pnt, user, __) {
          if (user.userId > 0 && user.userId != _subscribedUserId) {
            final token = ApiAuth.of(context, listen: false).token;
            _subscribe(context, pnt.value, token, user);
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
              padding: const EdgeInsets.fromLTRB(5.0, 5.0, 0.0, 0.0),
              child: _buildAvatar(n),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildHtmlWidget(context, n),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                    child: _buildTimestamp(context, n),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildAvatar(api.Notification n) => CircleAvatar(
        backgroundImage: CachedNetworkImageProvider(n.links.creatorAvatar),
      );

  Widget _buildHtmlWidget(BuildContext context, api.Notification n) {
    final w = n.notificationIsUnread ? FontWeight.bold : FontWeight.normal;
    final s = DefaultTextStyle.of(context).style.copyWith(fontWeight: w);

    return TinhteHtmlWidget(
      n.notificationHtml,
      hyperlinkColor: s.color,
      textStyle: s,
    );
  }

  Widget _buildTimestamp(BuildContext context, api.Notification n) => Text(
        formatTimestamp(context, n.notificationCreateDate),
        style: Theme.of(context).textTheme.caption,
      );

  void _fetchOnSuccess(Map json, FetchContext<api.Notification> fc) {
    if (json.containsKey('notifications')) {
      final list = json['notifications'] as List;
      fc.items.addAll(list.map((j) => api.Notification.fromJson(j)));
    }

    if (fc.id == FetchContextId.FetchInitial) {
      apiPost(ApiCaller.stateless(fc.state.context), 'notifications/read');
    }
  }

  void _onNotificationData(int newId) {
    final apiAuth = ApiAuth.of(context, listen: false);
    if (!apiAuth.hasToken) return;

    apiAuth.api
        .getJson("notifications?oauth_token=${apiAuth.token.accessToken}")
        .then((json) {
      if (!json.containsKey('notifications')) return;

      final list = json['notifications'] as List;
      final j = list.where((j) {
        if (!(j is Map)) return false;
        final m = j as Map;
        return m.containsKey('notification_id') &&
            m['notification_id'] == newId;
      });
      if (j.length != 1) return;

      final notification = api.Notification.fromJson(j.first);
      _slsKey.currentState?.itemsInsert(0, notification);
    });
  }

  void _subscribe(
    BuildContext context,
    String fcmToken,
    OauthToken token,
    User user,
  ) async {
    if (fcmToken?.isNotEmpty != true) return;

    final url = "${config.pushServer}/subscribe";
    final hubTopic = "user_notification_${user.userId}";
    final response = await http.post(
      url,
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
}

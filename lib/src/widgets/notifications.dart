import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tinhte_api/notification.dart' as api;

import '../api.dart';
import '../intl.dart';
import '../push_notification.dart';
import 'html.dart';
import 'super_list.dart';

class NotificationsWidget extends StatelessWidget {
  NotificationsWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) => SuperListView<api.Notification>(
        fetchPathInitial: 'notifications',
        fetchOnSuccess: _fetchOnSuccess,
        itemBuilder: (context, __, n) => _buildRow(context, n),
        itemStreamRegisterPrepend: (prepend) => listenToNotification(
            (i) => _onNotificationData(context, i, prepend)),
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

  Widget _buildHtmlWidget(BuildContext context, api.Notification n) => Theme(
        data: Theme.of(context).copyWith(
          accentColor: Theme.of(context).primaryColor,
          textTheme: Theme.of(context).textTheme.copyWith(
                body1: Theme.of(context).textTheme.title.copyWith(
                      fontWeight: n.notificationIsUnread
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
              ),
        ),
        child: TinhteHtmlWidget(
          n.notificationHtml,
        ),
      );

  Widget _buildTimestamp(BuildContext context, api.Notification n) => Text(
        formatTimestamp(n.notificationCreateDate),
        style: Theme.of(context).textTheme.caption,
      );

  void _fetchOnSuccess(Map json, FetchContext<api.Notification> fc) {
    if (json.containsKey('notifications')) {
      final list = json['notifications'] as List;
      list.forEach((j) => fc.addItem(api.Notification.fromJson(j)));
    }

    apiPost(fc.state, 'notifications/read');
  }

  void _onNotificationData(
    BuildContext context,
    int newId,
    void prepend(api.Notification n),
  ) =>
      ApiData.of(context).api.getJson('notifications').then((json) {
        if (!json.containsKey('notifications')) return;

        final list = json['notifications'] as List<Map>;
        final j = list.where((j) =>
            j.containsKey('notification_id') && j['notification_id'] == newId);
        if (j.length != 1) return;

        final notification = api.Notification.fromJson(j.first);
        prepend(notification);
      });
}

import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tinhte_api/notification.dart' as api;

import '../api.dart';
import '../intl.dart';
import '../push_notification.dart';
import '_list_view.dart';
import 'html.dart';

class NotificationsWidget extends StatefulWidget {
  NotificationsWidget({Key key}) : super(key: key);

  @override
  _NotificationsWidgetState createState() => _NotificationsWidgetState();
}

class _NotificationsWidgetState extends State<NotificationsWidget> {
  final List<api.Notification> notifications = List();

  StreamSubscription<int> _notifSub;
  bool _isFetching = false;

  @override
  void initState() {
    super.initState();
    fetch();
  }

  @override
  void dispose() {
    _notifSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListView.builder(
        itemBuilder: (context, i) => _isFetching
            ? buildProgressIndicator(true)
            : _buildRow(notifications[i]),
        itemCount: _isFetching ? 1 : notifications.length,
      );

  void fetch() {
    if (_isFetching) return;
    setState(() => _isFetching = true);

    return apiGet(
      this,
      'notifications',
      onSuccess: (jsonMap) {
        List<api.Notification> newNotifs = List();

        if (jsonMap.containsKey('notifications')) {
          final list = jsonMap['notifications'] as List;
          list.forEach((j) => newNotifs.add(api.Notification.fromJson(j)));
        }

        setState(() => notifications.addAll(newNotifs));

        _notifSub ??= listenToNotification(_onNotifData);
        apiPost(this, 'notifications/read');
      },
      onComplete: () => setState(() => _isFetching = false),
    );
  }

  Widget _buildRow(api.Notification n) => Card(
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
                  _buildHtmlWidget(n),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                    child: _buildTimestamp(n),
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

  Widget _buildHtmlWidget(api.Notification n) => Theme(
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

  Widget _buildTimestamp(api.Notification n) => Text(
        formatTimestamp(n.notificationCreateDate),
        style: Theme.of(context).textTheme.caption,
      );

  void _onNotifData(int newNotifId) =>
      apiGet(this, 'notifications', onSuccess: (jsonMap) {
        if (jsonMap.containsKey('notifications')) {
          final list = jsonMap['notifications'] as List;
          list.forEach((_j) {
            final j = _j as Map;
            if (!j.containsKey('notification_id')) return;

            // TODO: use /notifications/:id when it's available
            final notificationId = j['notification_id'];
            if (notificationId != newNotifId) return;

            final notification = api.Notification.fromJson(j);
            setState(() => notifications.insert(0, notification));
          });
        }
      });
}

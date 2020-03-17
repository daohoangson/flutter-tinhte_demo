import 'package:flutter/material.dart';
import 'package:tinhte_demo/src/widgets/notifications.dart';

class NotificationListScreen extends StatelessWidget {
  NotificationListScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Notifications'),
        ),
        body: NotificationsWidget(),
      );
}

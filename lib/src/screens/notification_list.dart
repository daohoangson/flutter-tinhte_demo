import 'package:flutter/material.dart';
import 'package:tinhte_demo/src/intl.dart';
import 'package:tinhte_demo/src/widgets/notifications.dart';

class NotificationListScreen extends StatelessWidget {
  const NotificationListScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(l(context).notifications),
        ),
        body: NotificationsWidget(),
      );
}

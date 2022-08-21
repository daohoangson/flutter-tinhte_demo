import 'package:flutter/material.dart';
import 'package:the_app/src/abstracts/push_notification.dart';

class PushNotificationWidget extends StatelessWidget {
  const PushNotificationWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        onChanged: null,
        value: backend != Backend.none,
      ),
      title: Text('push_notification'),
      subtitle: Text('$backend'),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:the_app/src/abstracts/push_notification.dart';

class PushNotificationWidget extends StatelessWidget {
  const PushNotificationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        onChanged: null,
        value: backend != Backend.none,
      ),
      title: const Text('push_notification'),
      subtitle: Text('$backend'),
    );
  }
}

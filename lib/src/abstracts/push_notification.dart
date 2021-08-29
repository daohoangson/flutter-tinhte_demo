import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'firebase.dart' as firebase;

typedef MessageListener = void Function(Map<String, dynamic> messageData);

void addListeners(
    MessageListener onMessage, MessageListener onMessageOpenedApp) {
  if (!firebase.isSupported) return;

  FirebaseMessaging.onMessage.listen((message) {
    debugPrint("FCM.onMessage: $message");
    onMessage(message.data);
  });
  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    debugPrint("FCM.onMessage: $message");
    onMessageOpenedApp(message.data);
  });
}

Future<Map<String, dynamic>> getInitialMessage() async {
  if (!firebase.isSupported) return null;

  final message = await FirebaseMessaging.instance.getInitialMessage();
  return message?.data;
}

Future<String> getToken() async {
  if (!firebase.isSupported) return '';

  final instance = FirebaseMessaging.instance;
  await instance.requestPermission();
  return instance.getToken();
}

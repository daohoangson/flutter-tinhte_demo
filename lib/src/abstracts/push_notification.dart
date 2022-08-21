import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'firebase.dart' as firebase;

final backend = firebase.isSupported ? Backend.firebaseMessaging : Backend.none;

void addListeners(
    MessageListener onMessage, MessageListener onMessageOpenedApp) {
  switch (backend) {
    case Backend.firebaseMessaging:
      FirebaseMessaging.onMessage.listen((message) {
        debugPrint("FCM.onMessage: $message");
        onMessage(message.data);
      });
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        debugPrint("FCM.onMessage: $message");
        onMessageOpenedApp(message.data);
      });
      break;
    case Backend.none:
      break;
  }
}

// ignore: missing_return
Future<Map<String, dynamic>?> getInitialMessage() async {
  switch (backend) {
    case Backend.firebaseMessaging:
      final message = await FirebaseMessaging.instance.getInitialMessage();
      return message?.data;
    case Backend.none:
      return null;
  }
}

// ignore: missing_return
Future<String?> getToken() async {
  switch (backend) {
    case Backend.firebaseMessaging:
      final instance = FirebaseMessaging.instance;
      await instance.requestPermission();
      return instance.getToken();
    case Backend.none:
      return null;
  }
}

enum Backend {
  firebaseMessaging,
  none,
}

typedef MessageListener = void Function(Map<String, dynamic> messageData);

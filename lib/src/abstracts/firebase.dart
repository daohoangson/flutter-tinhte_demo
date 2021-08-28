import 'dart:io';

import 'package:firebase_core/firebase_core.dart';

bool isSupported = Platform.isAndroid || Platform.isIOS;

Future<void> initializeApp() async {
  if (!isSupported) return;

  await Firebase.initializeApp();
}
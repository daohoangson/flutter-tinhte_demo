import 'dart:io';

import 'package:firebase_core/firebase_core.dart';

final isSupported = Platform.isAndroid || Platform.isIOS || Platform.isMacOS;

Future<void> initializeApp() async {
  if (!isSupported) return;

  await Firebase.initializeApp();
}

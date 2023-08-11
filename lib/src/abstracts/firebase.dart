import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:the_app/firebase_options.dart';

final isSupported = Platform.isAndroid || Platform.isIOS || Platform.isMacOS;

Future<void> initializeApp() async {
  if (!isSupported) return;

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

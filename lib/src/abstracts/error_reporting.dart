import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import 'firebase.dart' as firebase;

final backend =
    firebase.isSupported ? Backend.firebaseCrashlytics : Backend.none;

void configureErrorReporting() {
  if (backend == Backend.none) return;

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
}

void crash() => FirebaseCrashlytics.instance.crash();

enum Backend {
  firebaseCrashlytics,
  none,
}

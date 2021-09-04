import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import 'firebase.dart' as firebase;

final backend = kIsWeb
    ? Backend.none
    : firebase.isSupported
        ? Backend.firebaseCrashlytics
        : Backend.none;

void crash() => FirebaseCrashlytics.instance.crash();

// ignore: missing_return
R runZoned<R>(R Function() body) {
  switch (backend) {
    case Backend.firebaseCrashlytics:
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
      return runZonedGuarded(body, FirebaseCrashlytics.instance.recordError);
    case Backend.none:
      return body();
  }
}

enum Backend {
  firebaseCrashlytics,
  none,
}

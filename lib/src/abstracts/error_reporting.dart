import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import 'firebase.dart' as firebase;

R runZoned<R>(R Function() body) {
  if (!firebase.isSupported) {
    return body();
  }

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  return runZonedGuarded(body, FirebaseCrashlytics.instance.recordError);
}

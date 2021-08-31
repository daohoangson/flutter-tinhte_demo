import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart' as lib;
import 'package:the_app/src/intl.dart';

bool isSupported = Platform.isAndroid || Platform.isIOS;

final _googleSignIn = lib.GoogleSignIn(
  scopes: [
    'email',
  ],
);

Future<String> signIn(BuildContext context) async {
  final account = await _googleSignIn.signIn();
  if (account == null) {
    throw new StateError(l(context).loginGoogleErrorAccountIsNull);
  }

  final auth = await account.authentication;
  final googleToken = auth?.idToken ?? auth?.accessToken;
  if (googleToken.isNotEmpty != true) {
    throw new StateError(l(context).loginGoogleErrorTokenIsEmpty);
  }

  return googleToken;
}

Future<void> signOut() => _googleSignIn.signOut();

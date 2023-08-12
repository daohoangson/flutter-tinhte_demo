import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:the_app/src/intl.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart' as lib;

final isSupported = Platform.isIOS;

Future<String> signIn(BuildContext context) async {
  final l10n = l(context);

  try {
    final credential = await lib.SignInWithApple.getAppleIDCredential(
      scopes: [
        lib.AppleIDAuthorizationScopes.email,
      ],
    );
    return credential.identityToken!;
  } on lib.SignInWithAppleAuthorizationException catch (e) {
    if (e.code == lib.AuthorizationErrorCode.canceled) {
      throw StateError(l10n.loginErrorCancelled(l10n.loginWithApple));
    } else {
      throw StateError(e.message);
    }
  }
}

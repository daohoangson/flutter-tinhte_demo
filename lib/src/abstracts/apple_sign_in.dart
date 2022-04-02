import 'package:flutter/widgets.dart';
import 'package:the_app/src/intl.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart' as lib;

Future<bool> get isSupported => lib.TheAppleSignIn.isAvailable();

Future<String> signIn(BuildContext context) async {
  final req = lib.AppleIdRequest(requestedScopes: [lib.Scope.email]);

  final result = await lib.TheAppleSignIn.performRequests([req]);

  switch (result.status) {
    case lib.AuthorizationStatus.authorized:
      return String.fromCharCodes(result.credential.identityToken);
    case lib.AuthorizationStatus.cancelled:
      final _l = l(context);
      throw new StateError(_l.loginErrorCancelled(_l.loginWithApple));
    case lib.AuthorizationStatus.error:
      throw new StateError(result.error.localizedDescription);
  }

  throw new StateError(result.status.toString());
}

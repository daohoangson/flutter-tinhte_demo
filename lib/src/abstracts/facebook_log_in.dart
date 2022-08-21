import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart' as lib;
import 'package:the_app/src/intl.dart';

Future<String> logIn(BuildContext context) async {
  final l10n = l(context);
  final result = await lib.FacebookAuth.instance.login();
  switch (result.status) {
    case lib.LoginStatus.success:
      return result.accessToken!.token;
    case lib.LoginStatus.cancelled:
      throw StateError(l10n.loginErrorCancelled(l10n.loginWithFacebook));
    case lib.LoginStatus.failed:
      throw StateError('${result.status.name}: ${result.message}');
    case lib.LoginStatus.operationInProgress:
      throw StateError('${result.status.name}: ${result.message}');
  }
}

Future<void> logOut() => lib.FacebookAuth.instance.logOut();

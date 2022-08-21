import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart' as lib;
import 'package:the_app/src/intl.dart';

Future<String> logIn(BuildContext context) async {
  final result = await lib.FacebookAuth.instance.login();
  switch (result.status) {
    case lib.LoginStatus.success:
      return result.accessToken.token;
    case lib.LoginStatus.cancelled:
      final _l = l(context);
      throw StateError(_l.loginErrorCancelled(_l.loginWithFacebook));
    case lib.LoginStatus.failed:
      throw new StateError('${result.status.name}: ${result.message}');
    case lib.LoginStatus.operationInProgress:
      throw new StateError('${result.status.name}: ${result.message}');
  }

  throw new StateError(result.message ?? '');
}

Future<void> logOut() => lib.FacebookAuth.instance.logOut();

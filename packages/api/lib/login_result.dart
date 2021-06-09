import 'package:freezed_annotation/freezed_annotation.dart';

import 'oauth_token.dart';

part 'login_result.freezed.dart';

class LoginAssociatable {
  final Map<String, String> bodyFields;
  final ObtainMethod obtainMethod;
  final String username;

  LoginAssociatable._(
    this.bodyFields,
    this.obtainMethod,
    this.username,
  );

  static LoginAssociatable? fromJson(
    ObtainMethod obtainMethod,
    Map<String, dynamic> userData,
  ) {
    if (!userData.containsKey('associatable') ||
        !userData.containsKey('extra_data') ||
        !userData.containsKey('extra_timestamp')) return null;

    final entries = (userData['associatable'] as Map<String, dynamic>).entries;
    for (final entry in entries) {
      final Map<String, dynamic> value = entry.value;
      if (!value.containsKey('username')) continue;

      return LoginAssociatable._(
        Map.unmodifiable({
          'user_id': entry.key,
          'extra_data': userData['extra_data'],
          'extra_timestamp': userData['extra_timestamp'].toString(),
        }),
        obtainMethod,
        value['username'],
      );
    }

    return null;
  }
}

@freezed
class LoginTfa with _$LoginTfa {
  const factory LoginTfa(
    Map<String, String> bodyFields,
    ObtainMethod obtainMethod,
    String path,
    Iterable<String> providers, {
    String? triggeredProvider,
  }) = _LoginTfa;
}

@freezed
class LoginResult with _$LoginResult {
  const factory LoginResult.associatable(LoginAssociatable associatable) =
      _LoginResultAssociatable;

  const factory LoginResult.tfa(LoginTfa tfa) = _LoginResultTfa;

  const factory LoginResult.token(OauthToken token) = _LoginResultToken;
}

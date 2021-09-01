import 'package:freezed_annotation/freezed_annotation.dart';

part 'oauth_token.freezed.dart';
part 'oauth_token.g.dart';

abstract class OauthToken implements _$_OauthToken {
  factory OauthToken.fromJson(
      Map<String, dynamic> json, ObtainMethod? obtainMethod) {
    var data = _OauthToken.fromJson(json).copyWith(obtainMethod: obtainMethod);

    if (data.millisecondsSinceEpoch == null) {
      data = data.copyWith(
          millisecondsSinceEpoch: DateTime.now().millisecondsSinceEpoch);
    }

    return data;
  }
}

extension OauthTokenExtension on OauthToken {
  int get expiresAt {
    if (millisecondsSinceEpoch == null || expiresIn == null) {
      return DateTime.now().millisecondsSinceEpoch;
    }

    final expiresInInt = int.tryParse(expiresIn!);
    if (expiresInInt == null) {
      return DateTime.now().millisecondsSinceEpoch;
    }

    return millisecondsSinceEpoch! + expiresInInt * 1000;
  }

  bool get hasExpired => expiresAt < DateTime.now().millisecondsSinceEpoch;
}

@freezed
class _OauthToken with _$_OauthToken implements OauthToken {
  const factory _OauthToken(
    String? accessToken,
    String? refreshToken,
    String? scope,
    int? userId,
    String? expiresIn,
    int? millisecondsSinceEpoch,
    ObtainMethod? obtainMethod,
  ) = __OauthToken;

  factory _OauthToken.fromJson(Map<String, dynamic> json) =>
      _$_OauthTokenFromJson(json);
}

enum ObtainMethod {
  apple,
  facebook,
  google,
  storage,
  usernamePassword,
}

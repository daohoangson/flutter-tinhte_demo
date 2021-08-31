import 'package:freezed_annotation/freezed_annotation.dart';

part 'oauth_token.freezed.dart';
part 'oauth_token.g.dart';

@freezed
class OauthToken with _$OauthToken {
  const factory OauthToken({
    String? accessToken,
    String? refreshToken,
    String? scope,
    int? userId,
    @JsonKey(fromJson: int.parse) int? expiresIn,
    int? millisecondsSinceEpoch,
    ObtainMethod? obtainMethod,
  }) = _OauthToken;

  factory OauthToken.fromJson(Map<String, dynamic> json) =>
      _$OauthTokenFromJson(json).copyWith(
          millisecondsSinceEpoch: DateTime.now().millisecondsSinceEpoch);

  const OauthToken._();

  int get expiresAt {
    if (millisecondsSinceEpoch == null || expiresIn == null) {
      return DateTime.now().millisecondsSinceEpoch;
    }

    return millisecondsSinceEpoch! + expiresIn! * 1000;
  }

  bool get hasExpired => expiresAt < DateTime.now().millisecondsSinceEpoch;
}

enum ObtainMethod {
  apple,
  facebook,
  google,
  storage,
  usernamePassword,
}

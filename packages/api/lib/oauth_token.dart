import 'package:json_annotation/json_annotation.dart';

part 'oauth_token.g.dart';

@JsonSerializable()
class OauthToken {
  final String accessToken;
  final String refreshToken;
  final String scope;
  final int userId;

  @JsonKey(fromJson: int.parse)
  final int expiresIn;

  @JsonKey(ignore: true)
  final DateTime expiresAt;

  @JsonKey(ignore: true)
  ObtainMethod obtainMethod;

  OauthToken(
    this.accessToken,
    this.expiresIn,
    this.refreshToken,
    this.scope,
    this.userId,
  ) : expiresAt = DateTime.now().add(Duration(milliseconds: expiresIn * 1000));
  factory OauthToken.fromJson(Map<String, dynamic> json) =>
      _$OauthTokenFromJson(json);

  bool get hasExpired => expiresAt.isBefore(DateTime.now());
}

enum ObtainMethod {
  UsernamePassword,
  Apple,
  Facebook,
  Google,
}

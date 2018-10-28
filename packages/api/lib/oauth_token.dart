import 'package:json_annotation/json_annotation.dart';

part 'oauth_token.g.dart';

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
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
  ObtainMethod _obtainMethod;

  OauthToken(
    this.accessToken,
    this.expiresIn,
    this.refreshToken,
    this.scope,
    this.userId, {
    ObtainMethod obtainMethod,
  })  : expiresAt =
            DateTime.now().add(Duration(milliseconds: expiresIn * 1000)),
        _obtainMethod = obtainMethod;
  factory OauthToken.fromJson(
          ObtainMethod obtainMethod, Map<String, dynamic> json) =>
      _$OauthTokenFromJson(json).._obtainMethod = obtainMethod;

  bool get hasExpired => expiresAt.isBefore(DateTime.now());

  ObtainMethod get obtainMethod => _obtainMethod;
}

enum ObtainMethod {
  UsernamePassword,
  Facebook,
  Google,
}

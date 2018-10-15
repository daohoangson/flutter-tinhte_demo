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

  OauthToken(this.accessToken, this.expiresIn, this.refreshToken, this.scope,
      this.userId);
  factory OauthToken.fromJson(Map<String, dynamic> json) =>
      _$OauthTokenFromJson(json);
}

import 'package:freezed_annotation/freezed_annotation.dart';

part 'oauth_token.freezed.dart';
part 'oauth_token.g.dart';

int tokenExpireAt(OauthToken token) {
  final internal = token as _InternalOauthToken;
  final millisecondsSinceEpoch = internal.millisecondsSinceEpoch;
  final expiresInSeconds = internal.expiresIn;
  if (millisecondsSinceEpoch == null || expiresInSeconds == null)
    return DateTime.now().millisecondsSinceEpoch;

  return millisecondsSinceEpoch + expiresInSeconds * 1000;
}

bool tokenHasExpired(OauthToken token) =>
    tokenExpireAt(token) < DateTime.now().millisecondsSinceEpoch;

abstract class OauthToken {
  String? get accessToken;
  String? get refreshToken;
  String? get scope;
  int? get userId;
  ObtainMethod? get obtainMethod;

  factory OauthToken.fromJson(
    Map<String, dynamic> json, {
    ObtainMethod? obtainMethod,
  }) {
    final token = _InternalOauthToken.fromJson(json);
    return token.copyWith(
      millisecondsSinceEpoch:
          token.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch,
      obtainMethod: obtainMethod,
    );
  }

  factory OauthToken.fromStorage({
    String? accessToken,
    String? refreshToken,
    String? scope,
    int? userId,
    int? expiresAt,
  }) {
    final millisecondsSinceEpoch = DateTime.now().millisecondsSinceEpoch;
    final expiresIn = expiresAt != null
        ? ((expiresAt - millisecondsSinceEpoch) / 1000).floor()
        : null;

    return _InternalOauthToken(
      accessToken: accessToken,
      refreshToken: refreshToken,
      scope: scope,
      userId: userId,
      expiresIn: expiresIn,
      millisecondsSinceEpoch: millisecondsSinceEpoch,
      obtainMethod: ObtainMethod._Storage,
    );
  }
}

@freezed
class _InternalOauthToken with _$_InternalOauthToken implements OauthToken {
  const factory _InternalOauthToken({
    String? accessToken,
    String? refreshToken,
    String? scope,
    int? userId,
    @JsonKey(fromJson: int.parse) int? expiresIn,
    int? millisecondsSinceEpoch,
    ObtainMethod? obtainMethod,
  }) = __InternalOauthToken;

  factory _InternalOauthToken.fromJson(Map<String, dynamic> json) =>
      _$_InternalOauthTokenFromJson(json);
}

enum ObtainMethod {
  UsernamePassword,
  Apple,
  Facebook,
  Google,
  _Storage,
}

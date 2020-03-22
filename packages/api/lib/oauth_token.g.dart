// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'oauth_token.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OauthToken _$OauthTokenFromJson(Map<String, dynamic> json) {
  return OauthToken(
    json['access_token'] as String,
    int.parse(json['expires_in'] as String),
    json['refresh_token'] as String,
    json['scope'] as String,
    json['user_id'] as int,
  );
}

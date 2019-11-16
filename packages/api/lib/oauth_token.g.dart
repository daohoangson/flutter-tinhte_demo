// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'oauth_token.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OauthToken _$OauthTokenFromJson(Map<String, dynamic> json) {
  return OauthToken(
      json['access_token'] as String,
      json['expires_in'] == null
          ? null
          : int.parse(json['expires_in'] as String),
      json['refresh_token'] as String,
      json['scope'] as String,
      json['user_id'] as int,
      obtainMethod:
          _$enumDecodeNullable(_$ObtainMethodEnumMap, json['obtain_method']));
}

T _$enumDecode<T>(Map<T, dynamic> enumValues, dynamic source) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }
  return enumValues.entries
      .singleWhere((e) => e.value == source,
          orElse: () => throw ArgumentError(
              '`$source` is not one of the supported values: '
              '${enumValues.values.join(', ')}'))
      .key;
}

T _$enumDecodeNullable<T>(Map<T, dynamic> enumValues, dynamic source) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source);
}

const _$ObtainMethodEnumMap = <ObtainMethod, dynamic>{
  ObtainMethod.UsernamePassword: 'UsernamePassword',
  ObtainMethod.Facebook: 'Facebook',
  ObtainMethod.Google: 'Google'
};

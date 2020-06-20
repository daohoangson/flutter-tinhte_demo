part '../config.encrypted.dart';

abstract class Config {
  String get apiRoot;
  String get apiBookmarkPath;
  String get clientId;
  String get clientSecret;
  String get fcmProjectId;
  bool get loginWithApple;
  bool get loginWithFacebook;
  bool get loginWithGoogle;
  String get pushServer;
  String get siteRoot;

  const Config();
}

const config = _Config();

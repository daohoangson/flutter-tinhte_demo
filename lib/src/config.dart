part '../config.encrypted.dart';

abstract class Config {
  String get apiRoot;
  String get clientId;
  String get clientSecret;
  String get fcmProjectId;
  String get pushServer;
  String get siteRoot;

  const Config();
}

const config = _Config();

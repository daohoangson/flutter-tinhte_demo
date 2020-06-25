import 'package:flutter/widgets.dart';
import 'package:tinhte_api/search.dart';
import 'package:tinhte_api/thread.dart';
import 'package:tinhte_demo/src/widgets/super_list.dart';
import 'package:tinhte_demo/config.encrypted.dart';

abstract class ConfigBase {
  String get apiRoot;
  String get apiBookmarkPath => null;
  String get clientId;
  String get clientSecret;
  String get siteRoot;

  String get fcmProjectId => null;
  String get pushServer => null;

  List<SuperListComplexItemRegister> get homeComplexItems => null;
  String get homePath => 'threads/recent';
  SearchResult<Thread> Function(Map<dynamic, dynamic>) get homeParser => (j) {
        final thread = Thread.fromJson(j);
        if (thread.threadId != null) {
          return SearchResult<Thread>('thread', thread.threadId)
            ..content = thread;
        }
        return null;
      };
  Widget get homeSlot1BelowTop5 => null;
  Widget get homeSlot2BelowSlot1 => null;
  Widget get homeSlot3NearEndOfPage1 => null;
  Widget get homeSlot4EndOfPage1 => null;
  String get homeThreadsKey => 'data';

  bool get loginWithApple => false;
  bool get loginWithFacebook => false;
  bool get loginWithGoogle => false;

  bool get threadWidgetShowCoverImageOnly => true;
}

final config = Config();

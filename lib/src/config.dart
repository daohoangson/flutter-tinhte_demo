import 'package:flutter/widgets.dart';
import 'package:the_api/search.dart';
import 'package:the_api/thread.dart';
import 'package:the_app/src/widgets/super_list.dart';
import 'package:the_app/config.encrypted.dart';

abstract class ConfigBase {
  String get apiRoot;
  String? get apiBookmarkPath => null;
  String get clientId;
  String get clientSecret;
  String get linkPrivacyPolicy;
  String get siteRoot;

  String? get pushServer => null;

  List<SuperListComplexItemRegister>? get homeComplexItems => null;
  String get homePath => 'threads/recent';
  SearchResult<Thread> homeParser(Map<String, dynamic> json) {
    final thread = Thread.fromJson(json);
    return SearchResult<Thread>('thread', thread.threadId, content: thread);
  }

  Widget? get homeSlot1BelowTop5 => null;
  Widget? get homeSlot2BelowSlot1 => null;
  Widget? get homeSlot3NearEndOfPage1 => null;
  Widget? get homeSlot4EndOfPage1 => null;
  String get homeThreadsKey => 'data';

  bool get loginWithApple => false;
  bool get loginWithGoogle => false;

  bool get threadWidgetShowCoverImageOnly => true;
}

final ConfigBase config = Config();

import 'package:flutter/foundation.dart';

abstract class Followable extends ChangeNotifier {
  String? get followersLink;

  bool get isFollowed;
  set isFollowed(bool v);

  String get name;
}

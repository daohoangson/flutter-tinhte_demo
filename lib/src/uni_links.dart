import 'package:flutter/foundation.dart';
import 'package:the_app/src/link.dart';
import 'package:uni_links/uni_links.dart' as lib;

Future<String> getInitialPath() async {
  try {
    final initialLink = await lib.getInitialLink();
    if (initialLink == null) return null;

    final path = buildToolsParseLinkPath(initialLink);
    debugPrint('uni_links getInitialPath() -> $path');

    return path;
  } catch (e) {
    print(e);
  }

  return null;
}

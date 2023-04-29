import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:uni_links/uni_links.dart' as lib;

final isSupported = !kIsWeb && (Platform.isAndroid || Platform.isIOS);

Future<String?> getInitialLink() async {
  if (!isSupported) return null;
  return lib.getInitialLink();
}

StreamSubscription<String?>? listenToLinkStream(void Function(String?) onData) {
  if (!isSupported) return null;
  return lib.linkStream.listen(onData);
}

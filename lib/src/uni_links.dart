import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:the_app/src/abstracts/uni_links.dart' as abstraction;
import 'package:the_app/src/link.dart';
import 'package:the_app/src/push_notification.dart';

Future<String?> getInitialLink() async {
  try {
    final initialLink = await abstraction.getInitialLink();
    if (initialLink == null) return null;

    debugPrint('uni_links getInitialLink() -> $initialLink');
    return initialLink;
  } catch (e) {
    debugPrint('getInitialLink error: $e');
  }

  return null;
}

class UniLinksApp extends StatefulWidget {
  final Widget child;

  const UniLinksApp({required this.child, Key? key}) : super(key: key);

  @override
  State<UniLinksApp> createState() => _UniLinksState();
}

class _UniLinksState extends State<UniLinksApp> {
  late final StreamSubscription<String?>? subscription;

  @override
  void initState() {
    super.initState();
    subscription = abstraction.listenToLinkStream((event) {
      final link = event ?? '';
      if (link.isEmpty) return;

      final context = primaryNavKey.currentContext;
      if (context == null) {
        debugPrint('uni_links linkStream -> $link without context');
        return;
      }

      debugPrint('uni_links linkStream -> $link');
      launchLink(context, link);
    });
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

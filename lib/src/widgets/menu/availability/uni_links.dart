import 'package:flutter/material.dart';
import 'package:the_app/src/abstracts/uni_links.dart';

class UniLinksWidget extends StatelessWidget {
  const UniLinksWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        onChanged: null,
        value: isSupported,
      ),
      title: const Text('uni_links'),
    );
  }
}

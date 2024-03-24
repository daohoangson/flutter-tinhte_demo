import 'package:flutter/material.dart';
import 'package:the_app/src/abstracts/firebase.dart';

class FirebaseWidget extends StatelessWidget {
  const FirebaseWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        onChanged: null,
        value: isSupported,
      ),
      title: const Text('firebase'),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:the_app/src/abstracts/error_reporting.dart';

class ErrorReportingWidget extends StatelessWidget {
  const ErrorReportingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        onChanged: null,
        value: backend != Backend.none,
      ),
      title: const Text('error_reporting'),
      subtitle: Text('$backend'),
    );
  }
}

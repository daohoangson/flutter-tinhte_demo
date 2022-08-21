import 'package:flutter/material.dart';
import 'package:the_app/src/abstracts/error_reporting.dart';

class ErrorReportingWidget extends StatelessWidget {
  const ErrorReportingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        onChanged: null,
        value: backend != Backend.none,
      ),
      title: Text('error_reporting'),
      subtitle: Text('$backend'),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:the_app/src/intl.dart';
import 'package:the_app/src/widgets/navigation.dart';

class ForumListScreen extends StatelessWidget {
  const ForumListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(l(context).forums),
        ),
        body: const NavigationWidget(path: 'navigation?parent=0'),
      );
}

import 'package:flutter/material.dart';
import 'package:the_app/src/intl.dart';
import 'package:the_app/src/widgets/x_user_feed.dart';

class MyFeedScreen extends StatefulWidget {
  const MyFeedScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MyFeedScreenState();
}

class _MyFeedScreenState extends State<MyFeedScreen> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(l(context).myFeed),
        ),
        body: const UserFeedItems(),
      );
}

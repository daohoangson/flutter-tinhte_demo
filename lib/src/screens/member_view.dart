import 'package:flutter/material.dart';
import 'package:tinhte_api/user.dart';

import '../widgets/threads.dart';
import '../widgets/user/member_view_header.dart';
import '../api.dart';

class MemberViewScreen extends StatelessWidget {
  final User user;

  MemberViewScreen(this.user, {Key key})
      : assert(user != null),
        super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(user.username),
        ),
        body: ThreadsWidget(
          apiMethod: apiPost,
          header: MemberViewHeader(user),
          path: "search/threads?user_id=${user.userId}",
          threadsKey: 'data',
        ),
      );
}

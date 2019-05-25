import 'package:flutter/material.dart';
import 'package:tinhte_api/user.dart';

import '../widgets/user/member_view_header.dart';
import '../widgets/app_bar.dart';
import '../widgets/threads.dart';
import '../api.dart';
import 'search/thread.dart';

class MemberViewScreen extends StatelessWidget {
  final User user;

  MemberViewScreen(this.user, {Key key})
      : assert(user != null),
        super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: buildAppBar(
          title: Text(user.username),
        ),
        body: ThreadsWidget(
          apiMethod: apiPost,
          header: MemberViewHeader(user),
          path: "search/threads?user_id=${user.userId}",
          threadsKey: 'data',
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.search),
          onPressed: () => showSearch(
                context: context,
                delegate: ThreadSearchDelegate(user: user),
              ),
        ),
      );
}

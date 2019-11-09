import 'package:flutter/material.dart';
import 'package:tinhte_api/user.dart';

import '../widgets/user/member_view_header.dart';
import '../widgets/threads.dart';
import '../api.dart';
import 'search/thread.dart';

class MemberViewScreen extends StatefulWidget {
  final User user;

  MemberViewScreen(this.user, {Key key})
      : assert(user != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() => _MemberViewScreenState();
}

class _MemberViewScreenState extends State<MemberViewScreen> {
  var _fabIsVisible = true;

  User get user => widget.user;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(user.username),
        ),
        body: NotificationListener<ScrollNotification>(
          child: ThreadsWidget(
            apiMethod: apiPost,
            header: MemberViewHeader(user),
            path: "search/threads?user_id=${user.userId}",
            threadsKey: 'data',
          ),
          onNotification: (scrollInfo) {
            if (scrollInfo is ScrollUpdateNotification) {
              setState(() => _fabIsVisible = scrollInfo.scrollDelta < 0.0);
            }
            return false;
          },
        ),
        floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
        floatingActionButton: _fabIsVisible
            ? FloatingActionButton(
                child: Icon(Icons.search),
                onPressed: () => showSearch(
                      context: context,
                      delegate: ThreadSearchDelegate(user: user),
                    ),
              )
            : null,
      );
}

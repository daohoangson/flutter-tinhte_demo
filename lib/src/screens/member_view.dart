import 'package:flutter/material.dart';
import 'package:the_api/user.dart';
import 'package:the_app/src/intl.dart';
import 'package:the_app/src/screens/search/thread.dart';
import 'package:the_app/src/widgets/user/member_view_header.dart';
import 'package:the_app/src/widgets/threads.dart';
import 'package:the_app/src/api.dart';

class MemberViewScreen extends StatefulWidget {
  final User user;

  MemberViewScreen(this.user, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MemberViewScreenState();
}

class _MemberViewScreenState extends State<MemberViewScreen> {
  var _fabIsVisible = true;

  User get user => widget.user;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(user.username ?? ''),
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
              final scrollDelta = scrollInfo.scrollDelta;
              if (scrollDelta != null) {
                setState(() => _fabIsVisible = scrollDelta < 0.0);
              }
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
                tooltip: l(context).searchThisUser,
              )
            : null,
      );
}

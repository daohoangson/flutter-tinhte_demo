import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:tinhte_api/thread.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/app_bar.dart';
import '../widgets/posts.dart';
import '../intl.dart';
import '../link.dart';

const _kPopupActionOpenInBrowser = 'openInBrowser';
const _kPopupActionShare = 'share';

class ThreadViewScreen extends StatelessWidget {
  final Thread thread;
  final Map initialJson;

  ThreadViewScreen(
    this.thread, {
    this.initialJson,
    Key key,
  })  : assert(thread != null),
        super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: _buildAppBarTitle(context),
          actions: <Widget>[
            AppBarNotificationButton(),
            _buildAppBarPopupMenuButton(),
          ],
        ),
        body: _buildBody(),
      );

  Widget _buildAppBarPopupMenuButton() => PopupMenuButton<String>(
        itemBuilder: (context) => <PopupMenuEntry<String>>[
              PopupMenuItem(
                child: Text('Open in browser'),
                value: _kPopupActionOpenInBrowser,
              ),
              PopupMenuItem(
                child: Text('Share'),
                value: _kPopupActionShare,
              ),
            ],
        onSelected: (value) {
          switch (value) {
            case _kPopupActionOpenInBrowser:
              launch(thread.links?.permalink);
              break;
            case _kPopupActionShare:
              Share.share(thread.links?.permalink);
              break;
          }
        },
      );

  Widget _buildAppBarTitle(BuildContext context) => GestureDetector(
        child: Row(
          children: <Widget>[
            CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(
                thread.links?.firstPosterAvatar,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 7.5,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Text(
                      thread.creatorUsername,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: (kToolbarHeight - 10) / 2),
                    ),
                    Text(
                      formatTimestamp(thread.threadCreateDate),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: (kToolbarHeight - 10) / 4),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        onTap: () => launchMemberView(context, thread.creatorUserId),
      );

  Widget _buildBody() => PostsWidget(
        path: thread.links?.posts,
        initialJson: initialJson,
        thread: thread,
      );
}

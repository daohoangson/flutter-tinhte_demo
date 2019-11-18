import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:tinhte_api/thread.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/app_bar.dart';
import '../widgets/post_editor.dart';
import '../widgets/posts.dart';
import '../intl.dart';
import '../link.dart';

const _kPopupActionOpenInBrowser = 'openInBrowser';
const _kPopupActionShare = 'share';

class ThreadViewScreen extends StatefulWidget {
  final Thread thread;
  final Map initialJson;

  ThreadViewScreen(
    this.thread, {
    this.initialJson,
    Key key,
  })  : assert(thread != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() => _ThreadViewState();
}

class _ThreadViewState extends State<ThreadViewScreen> {
  final _postsKey = GlobalKey<PostsState>();

  PostEditorData _ped;

  Map get initialJson => widget.initialJson;
  Thread get thread => widget.thread;

  @override
  void initState() {
    super.initState();
    _ped = PostEditorData(thread);
  }

  @override
  void dispose() {
    _ped.dispose();
    super.dispose();
  }

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
                    _buildAppBarUsername(),
                    Text(
                      formatTimestamp(thread.threadCreateDate),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: (kToolbarHeight - 10) / 4),
                      textScaleFactor: 1,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        onTap: () => launchMemberView(context, thread.creatorUserId),
      );

  Widget _buildAppBarUsername() {
    final fontSize = (kToolbarHeight - 10) / 2;
    final buffer = StringBuffer(thread.creatorUsername);
    final inlineSpans = <InlineSpan>[];

    if (thread.creatorHasVerifiedBadge == true) {
      buffer.write(' ');
      final icon = Icon(FontAwesomeIcons.solidCheckCircle, size: fontSize);
      inlineSpans.add(WidgetSpan(child: icon));
    }

    return Builder(
        builder: (context) => RichText(
              text: TextSpan(
                children: inlineSpans,
                text: buffer.toString(),
                style: DefaultTextStyle.of(context)
                    .style
                    .copyWith(fontSize: fontSize),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textScaleFactor: 1,
            ));
  }

  Widget _buildBody() => MultiProvider(
        child: Column(
          children: <Widget>[
            Expanded(
              child: PostsWidget(
                thread,
                key: _postsKey,
                path: thread.links?.posts,
                initialJson: initialJson,
              ),
            ),
            Container(
              child: PostEditorWidget(
                callback: (p) => _postsKey.currentState?.insertNewPost(p),
              ),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(
                kPaddingHorizontal,
                kPaddingHorizontal / 2,
                kPaddingHorizontal,
                kPaddingHorizontal / 4,
              ),
            ),
          ],
        ),
        providers: [
          ChangeNotifierProvider<PostEditorData>.value(value: _ped),
        ],
      );
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:tinhte_api/thread.dart';
import 'package:the_app/src/widgets/font_control.dart';
import 'package:the_app/src/widgets/post_editor.dart';
import 'package:the_app/src/widgets/posts.dart';
import 'package:the_app/src/intl.dart';
import 'package:the_app/src/link.dart';
import 'package:the_app/src/widgets/thread/thread_bookmark.dart';
import 'package:url_launcher/url_launcher.dart';

const _kPopupActionOpenInBrowser = 'openInBrowser';
const _kPopupActionShare = 'share';

class ThreadViewScreen extends StatefulWidget {
  final bool enablePostEditor;
  final Map initialJson;
  final Thread thread;

  ThreadViewScreen(
    this.thread, {
    this.enablePostEditor = false,
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

    if (widget.enablePostEditor)
      WidgetsBinding.instance.addPostFrameCallback((_) => _ped.enable(context));
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
            FontControlWidget(),
            ThreadBookmarkWidget(widget.thread),
            _buildAppBarPopupMenuButton(),
          ],
        ),
        body: _buildBody(),
      );

  Widget _buildAppBarPopupMenuButton() => PopupMenuButton<String>(
        itemBuilder: (context) => <PopupMenuEntry<String>>[
          PopupMenuItem(
            child: Text(l(context).openInBrowser),
            value: _kPopupActionOpenInBrowser,
          ),
          PopupMenuItem(
            child: Text(l(context).share),
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
                      formatTimestamp(context, thread.threadCreateDate),
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
      inlineSpans.add(WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Icon(FontAwesomeIcons.solidCheckCircle, size: fontSize),
      ));
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
                paddingHorizontal: kPaddingHorizontal,
                paddingVertical: kPaddingHorizontal / 2,
              ),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
            ),
          ],
        ),
        providers: [
          ChangeNotifierProvider<PostEditorData>.value(value: _ped),
        ],
      );
}

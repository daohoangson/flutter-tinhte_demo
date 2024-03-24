import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:the_api/thread.dart';
import 'package:the_app/src/abstracts/cached_network_image.dart' as cached;
import 'package:the_app/src/constants.dart';
import 'package:the_app/src/widgets/font_control.dart';
import 'package:the_app/src/widgets/post_editor.dart';
import 'package:the_app/src/widgets/posts.dart';
import 'package:the_app/src/intl.dart';
import 'package:the_app/src/link.dart';
import 'package:the_app/src/widgets/thread/thread_bookmark.dart';

const _kPopupActionOpenInBrowser = 'openInBrowser';
const _kPopupActionShare = 'share';

class ThreadViewScreen extends StatefulWidget {
  final bool enablePostEditor;
  final Map? initialJson;
  final Thread thread;

  const ThreadViewScreen(
    this.thread, {
    this.enablePostEditor = false,
    this.initialJson,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _ThreadViewState();
}

class _ThreadViewState extends State<ThreadViewScreen> {
  final _postsKey = GlobalKey<PostsState>();

  late final PostEditorData _ped;

  Map? get initialJson => widget.initialJson;
  Thread get thread => widget.thread;

  @override
  void initState() {
    super.initState();
    _ped = PostEditorData(thread);

    if (widget.enablePostEditor) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _ped.enable(context));
    }
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
            const FontControlWidget(),
            ThreadBookmarkWidget(widget.thread),
            _buildAppBarPopupMenuButton(),
          ],
        ),
        body: _buildBody(),
      );

  Widget _buildAppBarPopupMenuButton() {
    final permalink = thread.links?.permalink;
    if (permalink == null) {
      return const SizedBox.shrink();
    }

    return PopupMenuButton<String>(
      itemBuilder: (context) => <PopupMenuEntry<String>>[
        PopupMenuItem(
          value: _kPopupActionOpenInBrowser,
          child: Text(l(context).openInBrowser),
        ),
        PopupMenuItem(
          value: _kPopupActionShare,
          child: Text(l(context).share),
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case _kPopupActionOpenInBrowser:
            launchLink(context, permalink, forceWebView: true);
            break;
          case _kPopupActionShare:
            Share.share(permalink);
            break;
        }
      },
    );
  }

  Widget _buildAppBarTitle(BuildContext context) {
    final avatar = thread.links?.firstPosterAvatar;

    Widget built = Row(
      children: <Widget>[
        CircleAvatar(
          backgroundImage: avatar != null ? cached.image(avatar) : null,
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
                  style: const TextStyle(fontSize: (kToolbarHeight - 10) / 4),
                  textScaler: TextScaler.noScaling,
                ),
              ],
            ),
          ),
        ),
      ],
    );

    final creatorUserId = thread.creatorUserId;
    if (creatorUserId != null) {
      built = GestureDetector(
        child: built,
        onTap: () => launchMemberView(context, creatorUserId),
      );
    }

    return built;
  }

  Widget _buildAppBarUsername() {
    const fontSize = (kToolbarHeight - 10) / 2;
    final buffer = StringBuffer(thread.creatorUsername ?? '');
    final inlineSpans = <InlineSpan>[];

    if (thread.creatorHasVerifiedBadge == true) {
      buffer.write(' ');
      inlineSpans.add(const WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Icon(
          FontAwesomeIcons.solidCircleCheck,
          size: fontSize,
        ),
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
        providers: [
          ChangeNotifierProvider<PostEditorData>.value(value: _ped),
        ],
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
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
              child: PostEditorWidget(
                callback: (p) => _postsKey.currentState?.insertNewPost(p),
                paddingHorizontal: kPadding,
                paddingVertical: kPadding / 2,
              ),
            ),
          ],
        ),
      );
}

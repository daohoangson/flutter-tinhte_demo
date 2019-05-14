import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tinhte_api/post.dart';
import 'package:tinhte_api/thread.dart';

import '../../screens/thread_view.dart';
import '../../api.dart';
import '../../intl.dart';
import '../image.dart';

const _kPaddingHorizontal = EdgeInsets.symmetric(horizontal: 10.0);

class HomeThreadWidget extends StatelessWidget {
  final Thread thread;

  HomeThreadWidget(this.thread, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 600),
          child: _buildCard(
            context,
            <Widget>[
              _buildImage(),
              const SizedBox(height: 10.0),
              _buildTextPadding(_buildInfoRow(context)),
              const SizedBox(height: 5.0),
              _buildTextPadding(_buildTitle(context)),
              const SizedBox(height: 10.0),
              _HomeThreadActionsWidget(thread),
            ],
          ),
        ),
      );

  Widget _buildCard(BuildContext context, List<Widget> children) => Card(
        margin: const EdgeInsets.only(bottom: 10.0),
        child: GestureDetector(
          child: Column(
            children: children,
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
          onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => ThreadViewScreen(thread)),
              ),
        ),
      );

  Widget _buildImage() =>
      ThreadImageWidget(image: thread?.threadImage, threadId: thread?.threadId);

  Widget _buildInfoRow(BuildContext context) {
    final List<TextSpan> spans = List();
    final theme = Theme.of(context);

    spans.add(TextSpan(
      style: TextStyle(
        color: thread != null ? theme.accentColor : theme.disabledColor,
        fontWeight: FontWeight.bold,
      ),
      text: thread?.creatorUsername ?? '■ ●● ▲▲▲',
    ));

    if (thread?.threadCreateDate != null) {
      final threadCreateDate = formatTimestamp(thread.threadCreateDate);
      spans.add(TextSpan(text: " - $threadCreateDate"));
    }

    final threadViewCount = thread?.threadViewCount ?? 0;
    if (threadViewCount > 1500) {
      spans.add(TextSpan(text: " - ${formatNumber(threadViewCount)} views"));
    }

    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        children: spans,
        style: theme.textTheme.body1,
      ),
    );
  }

  Widget _buildTextPadding(Widget child) =>
      Padding(padding: _kPaddingHorizontal, child: child);

  Widget _buildTitle(BuildContext context) => Text(
        thread?.threadTitle ?? '▲  □■   ○●○    ▼◁▲▷',
        maxLines: 3,
        style: Theme.of(context).textTheme.title,
      );
}

class _HomeThreadActionsWidget extends StatefulWidget {
  final Thread thread;

  _HomeThreadActionsWidget(this.thread, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomeThreadActionsWidgetState();
}

class _HomeThreadActionsWidgetState extends State<_HomeThreadActionsWidget> {
  bool isLiking = false;

  String get linkLikes => post?.links?.likes;
  Post get post => thread?.firstPost;
  bool get postIsLiked => post?.postIsLiked == true;
  int get postLikeCount => post?.postLikeCount ?? 0;
  Thread get thread => widget.thread;
  int get threadPostCount => thread?.threadPostCount ?? 0;

  set postIsLiked(bool value) => post?.postIsLiked = value;
  set postLikeCount(int value) => post?.postLikeCount = value;

  @override
  Widget build(BuildContext context) => Column(children: <Widget>[
        DefaultTextStyle(
          style: Theme.of(context).textTheme.caption,
          child: Padding(
            padding: _kPaddingHorizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _buildCounterLike(),
                _buildCounterPost(),
              ],
            ),
          ),
        ),
        Divider(indent: 10.0),
        IconTheme(
          data: Theme.of(context).iconTheme.copyWith(size: 20.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: _buildButtonLike(),
              ),
              Expanded(
                child: FlatButton.icon(
                  icon: Icon(FontAwesomeIcons.commentAlt),
                  label: Text('Reply'),
                  onPressed: null,
                ),
              ),
              Expanded(
                child: FlatButton.icon(
                  icon: Icon(FontAwesomeIcons.shareAlt),
                  label: Text('Share'),
                  onPressed: null,
                ),
              ),
            ],
          ),
        ),
      ]);

  _buildButtonLike() => FlatButton.icon(
        icon: postIsLiked
            ? const Icon(FontAwesomeIcons.solidHeart)
            : const Icon(FontAwesomeIcons.heart),
        label: postIsLiked ? const Text('Unlike') : const Text('Like'),
        onPressed: isLiking
            ? null
            : linkLikes?.isNotEmpty != true
                ? null
                : postIsLiked ? _unlikePost : _likePost,
      );

  _buildCounterLike() => postLikeCount > 0
      ? Row(
          children: <Widget>[
            Icon(
              FontAwesomeIcons.solidHeart,
              color: Theme.of(context).accentColor,
              size: 13.0,
            ),
            Text(" ${formatNumber(postLikeCount)}"),
          ],
        )
      : Container(height: 0.0, width: 0.0);

  _buildCounterPost() => threadPostCount > 0
      ? Text("${formatNumber(threadPostCount)} Posts")
      : Container(height: 0.0, width: 0.0);

  _likePost() => prepareForApiAction(this, () {
        if (isLiking) return;
        setState(() => isLiking = true);

        apiPost(this, linkLikes,
            onSuccess: (_) => setState(() {
                  postIsLiked = true;
                  postLikeCount++;
                }),
            onComplete: () => setState(() => isLiking = false));
      });

  _unlikePost() => prepareForApiAction(this, () {
        if (isLiking) return;
        setState(() => isLiking = true);

        apiDelete(this, linkLikes,
            onSuccess: (_) => setState(() {
                  postIsLiked = false;
                  if (postLikeCount > 0) postLikeCount--;
                }),
            onComplete: () => setState(() => isLiking = false));
      });
}

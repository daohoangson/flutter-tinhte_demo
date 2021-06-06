import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:the_api/search.dart';
import 'package:the_api/thread.dart';
import 'package:the_api/x_content_list.dart';
import 'package:the_app/src/constants.dart';
import 'package:the_app/src/screens/thread_view.dart';
import 'package:the_app/src/intl.dart';
import 'package:the_app/src/widgets/image.dart';

class HomeThreadWidget extends StatelessWidget {
  final ContentListItem item;
  final Thread thread;

  HomeThreadWidget(
    SearchResult<Thread> srt, {
    Key key,
  })  : assert(srt?.content != null),
        item = srt.listItem,
        thread = srt.content,
        super(key: key);

  @override
  Widget build(BuildContext _) => LayoutBuilder(
        builder: (context, bc) {
          final theme = Theme.of(context);
          final isWide = bc.maxWidth > 480;

          return Padding(
            child: _buildBox(
              context,
              <Widget>[
                _buildImage(isWide ? 1 : 0.75),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    children: <Widget>[
                      _buildInfo(context, theme),
                      const SizedBox(height: 5),
                      _buildTitle(),
                      const SizedBox(height: 5),
                      isWide
                          ? _buildSnippet(theme.textTheme.caption)
                          : SizedBox.shrink(),
                    ],
                    crossAxisAlignment: CrossAxisAlignment.start,
                  ),
                ),
              ],
            ),
            padding: const EdgeInsets.all(10),
          );
        },
      );

  Widget _buildBox(BuildContext context, List<Widget> children) => InkWell(
        child: Row(
          children: children,
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ThreadViewScreen(thread)),
        ),
      );

  Widget _buildImage(double imageScale) => ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: SizedBox(
          child: ThreadImageWidget.small(
              thread, thread.threadThumbnail ?? thread.threadImage),
          width: kThreadThumbnailWidth * imageScale,
        ),
      );

  Widget _buildInfo(BuildContext context, ThemeData theme) {
    final spans = <TextSpan>[];

    spans.add(TextSpan(
      style: TextStyle(color: theme.accentColor),
      text: thread.creatorUsername,
    ));

    if (item?.itemDate != null) {
      spans.add(TextSpan(text: " ${formatTimestamp(context, item.itemDate)}"));
    }

    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        children: spans,
        style: theme.textTheme.caption,
      ),
    );
  }

  Widget _buildSnippet(TextStyle style) => Text(
        thread.firstPost.postBodyPlainText,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: style,
      );

  Widget _buildTitle() => Text(thread.threadTitle);
}

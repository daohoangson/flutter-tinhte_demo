import 'package:flutter/material.dart';
import 'package:tinhte_api/content_list.dart';
import 'package:tinhte_api/thread.dart';

import '../../screens/thread_view.dart';
import '../../intl.dart';
import '../image.dart';

class HomeThreadWidget extends StatelessWidget {
  final double imageWidth;
  final ListItem item;
  final Thread thread;

  HomeThreadWidget(
    ThreadListItem tli, {
    this.imageWidth,
    Key key,
  })  : assert(tli?.item != null),
        assert(tli?.thread != null),
        assert(imageWidth != null),
        item = tli.item,
        thread = tli.thread,
        super(key: key);

  @override
  Widget build(BuildContext _) => LayoutBuilder(
        builder: (context, box) => Padding(
              child: _buildBox(
                context,
                <Widget>[
                  _buildImage(box.maxWidth > 480 ? 1 : 0.75),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        _buildInfo(Theme.of(context)),
                        const SizedBox(height: 5),
                        _buildTitle(),
                      ],
                      crossAxisAlignment: CrossAxisAlignment.start,
                    ),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(10),
            ),
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
          child: ThreadImageWidget(
            image: thread.threadThumbnail,
            threadId: thread.threadId,
          ),
          width: imageWidth * imageScale,
        ),
      );

  Widget _buildInfo(ThemeData theme) {
    final List<TextSpan> spans = List();

    spans.add(TextSpan(
      style: TextStyle(color: theme.accentColor),
      text: thread.creatorUsername,
    ));

    if (item?.itemDate != null) {
      spans.add(TextSpan(text: " ${formatTimestamp(item.itemDate)}"));
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

  Widget _buildTitle() => Text(
        thread.threadTitle,
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
      );
}

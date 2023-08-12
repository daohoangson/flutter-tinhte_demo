import 'package:flutter/material.dart';
import 'package:the_api/search.dart';
import 'package:the_api/thread.dart';
import 'package:the_api/x_content_list.dart';
import 'package:the_app/src/screens/thread_view.dart';
import 'package:the_app/src/intl.dart';
import 'package:the_app/src/widgets/image.dart';

class HomeTop5Widget extends StatelessWidget {
  final List<SearchResult<Thread>> items;

  const HomeTop5Widget(this.items, {Key? key})
      : assert(items.length == 5),
        super(key: key);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(10),
        child: LayoutBuilder(
          builder: (_, box) => box.maxWidth > 480
              ? _build23(
                  _HomeTop5WidgetThread(items[0]),
                  _HomeTop5WidgetThread(items[1]),
                  _HomeTop5WidgetThread(items[2]),
                  _HomeTop5WidgetThread(items[3]),
                  _HomeTop5WidgetThread(items[4]),
                )
              : _build122(
                  _HomeTop5WidgetThread(items[0]),
                  _HomeTop5WidgetThread(items[1]),
                  _HomeTop5WidgetThread(items[2]),
                  _HomeTop5WidgetThread(items[3]),
                  _HomeTop5WidgetThread(items[4]),
                ),
        ),
      );

  Widget _build122(Widget w1, Widget w21, Widget w22, Widget w31, Widget w32) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          w1,
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(child: w21),
              const SizedBox(width: 10),
              Expanded(child: w22),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(child: w31),
              const SizedBox(width: 10),
              Expanded(child: w32),
            ],
          ),
        ],
      );

  Widget _build23(Widget w11, Widget w12, Widget w21, Widget w22, Widget w23) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(child: w11),
              const SizedBox(width: 10),
              Expanded(child: w12),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(child: w21),
              const SizedBox(width: 10),
              Expanded(child: w22),
              const SizedBox(width: 10),
              Expanded(child: w23),
            ],
          ),
        ],
      );
}

class _HomeTop5WidgetThread extends StatelessWidget {
  final ContentListItem? item;
  final Thread thread;

  _HomeTop5WidgetThread(SearchResult<Thread> srt, {Key? key})
      : assert(srt.content != null),
        item = srt.listItem,
        thread = srt.content!,
        super(key: key);

  @override
  Widget build(BuildContext context) => _buildBox(
        context,
        <Widget>[
          _buildImage(),
          const SizedBox(height: 5),
          _buildInfo(context),
          const SizedBox(height: 5),
          _buildTitle(),
        ],
      );

  Widget _buildBox(BuildContext context, List<Widget> children) => InkWell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ThreadViewScreen(thread)),
        ),
      );

  Widget _buildImage() => ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: LayoutBuilder(
          builder: (context, box) => ThreadImageWidget.small(
              thread, _chooseImageForBox(thread, context, box)),
        ),
      );

  Widget _buildInfo(BuildContext context) {
    final theme = Theme.of(context);
    final spans = <TextSpan>[];

    spans.add(TextSpan(
      style: TextStyle(color: theme.colorScheme.secondary),
      text: thread.creatorUsername,
    ));

    final itemDate = item?.itemDate;
    if (itemDate != null) {
      spans.add(TextSpan(text: " ${formatTimestamp(context, itemDate)}"));
    }

    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        children: spans,
        style: theme.textTheme.bodySmall,
      ),
    );
  }

  Widget _buildTitle() => Text(thread.threadTitle ?? '#${thread.threadId}');

  ThreadImage? _chooseImageForBox(Thread t, BuildContext c, BoxConstraints bc) {
    final thumbnail = t.threadThumbnail;
    if (thumbnail == null) return t.threadImage;

    final thumbnailSize = thumbnail.size;
    if (thumbnailSize == null) return t.threadImage;

    final devicePixelRatio = MediaQuery.of(c).devicePixelRatio;
    switch (thumbnail.mode) {
      case 'sh':
        if (devicePixelRatio * bc.maxWidth < thumbnailSize) return thumbnail;
        break;
      case 'sw':
        if (devicePixelRatio * bc.maxHeight < thumbnailSize) return thumbnail;
        break;
    }

    return t.threadImage;
  }
}

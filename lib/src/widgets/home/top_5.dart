import 'package:flutter/material.dart';
import 'package:tinhte_api/content_list.dart';
import 'package:tinhte_api/thread.dart';

import '../../screens/thread_view.dart';
import '../../intl.dart';
import '../image.dart';

class HomeTop5Widget extends StatelessWidget {
  final List<ThreadListItem> items;

  HomeTop5Widget(this.items, {Key key})
      : assert(items?.length == 5),
        super(key: key);

  @override
  Widget build(BuildContext _) => Padding(
        child: LayoutBuilder(
          builder: (_, box) => box.maxWidth > 480
              ? _build23(
                  _HomeTop5WidgetThread(items[0], maxLines: 4),
                  _HomeTop5WidgetThread(items[1], maxLines: 4),
                  _HomeTop5WidgetThread(items[2], maxLines: 4),
                  _HomeTop5WidgetThread(items[3], maxLines: 4),
                  _HomeTop5WidgetThread(items[4], maxLines: 4),
                )
              : _build122(
                  _HomeTop5WidgetThread(items[0]),
                  _HomeTop5WidgetThread(items[1], maxLines: 4),
                  _HomeTop5WidgetThread(items[2], maxLines: 4),
                  _HomeTop5WidgetThread(items[3], maxLines: 4),
                  _HomeTop5WidgetThread(items[4], maxLines: 4),
                ),
        ),
        padding: const EdgeInsets.all(10),
      );

  Widget _build122(Widget w1, Widget w21, Widget w22, Widget w31, Widget w32) =>
      Column(
        children: <Widget>[
          w1,
          const SizedBox(height: 10),
          AspectRatio(
            child: Row(children: <Widget>[
              Expanded(child: w21),
              const SizedBox(width: 10),
              Expanded(child: w22),
            ]),
            aspectRatio: 1.5,
          ),
          Row(children: <Widget>[
            Expanded(child: w31),
            const SizedBox(width: 10),
            Expanded(child: w32),
          ]),
        ],
        crossAxisAlignment: CrossAxisAlignment.stretch,
      );

  Widget _build23(Widget w11, Widget w12, Widget w21, Widget w22, Widget w23) =>
      Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(child: w11),
              const SizedBox(width: 10),
              Expanded(child: w12),
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Expanded(child: w21),
              const SizedBox(width: 10),
              Expanded(child: w22),
              const SizedBox(width: 10),
              Expanded(child: w23),
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
        ],
        crossAxisAlignment: CrossAxisAlignment.stretch,
      );
}

class _HomeTop5WidgetThread extends StatelessWidget {
  final ListItem item;
  final int maxLines;
  final Thread thread;

  _HomeTop5WidgetThread(
    ThreadListItem tli, {
    Key key,
    this.maxLines = 2,
  })  : assert(tli?.item != null),
        assert(tli?.thread != null),
        item = tli.item,
        thread = tli.thread,
        super(key: key);

  @override
  Widget build(BuildContext context) => _buildBox(
        context,
        <Widget>[
          _buildImage(),
          const SizedBox(height: 5),
          _buildInfo(Theme.of(context)),
          const SizedBox(height: 5),
          _buildTitle(),
        ],
      );

  Widget _buildBox(BuildContext context, List<Widget> children) => InkWell(
        child: Column(
          children: children,
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ThreadViewScreen(thread)),
            ),
      );

  Widget _buildImage() => ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: LayoutBuilder(
          builder: (_, box) => ThreadImageWidget(
                image: _chooseImageForBox(thread, box),
                threadId: thread.threadId,
              ),
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
        maxLines: maxLines,
      );

  ThreadImage _chooseImageForBox(Thread thread, BoxConstraints box) {
    if (thread.threadThumbnail == null) return thread.threadImage;

    final thumbnail = thread.threadThumbnail;
    switch (thumbnail.mode) {
      case 'sh':
        if (box.maxWidth < thumbnail.size) return thumbnail;
        break;
      case 'sw':
        if (box.maxHeight < thumbnail.size) return thumbnail;
        break;
    }

    return thread.threadImage;
  }
}

import 'package:flutter/material.dart';
import 'package:the_api/search.dart';
import 'package:the_api/thread.dart';
import 'package:the_api/x_content_list.dart';
import 'package:the_app/src/screens/thread_view.dart';
import 'package:the_app/src/intl.dart';
import 'package:the_app/src/widgets/image.dart';

class HomeTop5Widget extends StatelessWidget {
  final List<SearchResult<Thread>> items;

  HomeTop5Widget(this.items, {Key key})
      : assert(items?.length == 5),
        super(key: key);

  @override
  Widget build(BuildContext _) => Padding(
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
        padding: const EdgeInsets.all(10),
      );

  Widget _build122(Widget w1, Widget w21, Widget w22, Widget w31, Widget w32) =>
      Column(
        children: <Widget>[
          w1,
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Expanded(child: w21),
              const SizedBox(width: 10),
              Expanded(child: w22),
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Expanded(child: w31),
              const SizedBox(width: 10),
              Expanded(child: w32),
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
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
  final ContentListItem item;
  final Thread thread;

  _HomeTop5WidgetThread(SearchResult<Thread> srt, {Key key})
      : assert(srt?.content != null),
        item = srt.listItem,
        thread = srt.content,
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
          builder: (context, box) => ThreadImageWidget(
            image: _chooseImageForBox(thread, context, box),
            threadId: thread.threadId,
          ),
        ),
      );

  Widget _buildInfo(BuildContext context) {
    final theme = Theme.of(context);
    final List<TextSpan> spans = List();

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

  Widget _buildTitle() => Text(thread.threadTitle);

  ThreadImage _chooseImageForBox(Thread t, BuildContext c, BoxConstraints bc) {
    if (t.threadThumbnail == null) return getThreadImage(t);

    final devicePixelRatio = MediaQuery.of(c).devicePixelRatio;
    final thumbnail = t.threadThumbnail;
    switch (thumbnail.mode) {
      case 'sh':
        if (devicePixelRatio * bc.maxWidth < thumbnail.size) return thumbnail;
        break;
      case 'sw':
        if (devicePixelRatio * bc.maxHeight < thumbnail.size) return thumbnail;
        break;
    }

    return getThreadImage(t);
  }
}

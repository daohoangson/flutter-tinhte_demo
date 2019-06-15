import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tinhte_api/thread.dart';

import '../../screens/thread_view.dart';
import '../../api.dart';
import '../../intl.dart';
import 'header.dart';

const _kTopThreadHeight = 200.0;
const _kTopThreadPadding = 5.0;

class TopThreadsWidget extends StatefulWidget {
  State<StatefulWidget> createState() => _TopThreadsWidgetState();
}

class _TopThreadsWidgetState extends State<TopThreadsWidget> {
  final _threads = <Thread>[];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  Widget build(BuildContext _) => LayoutBuilder(
        builder: (context, bc) {
          final isWide = bc.maxWidth > 600;
          final height = _kTopThreadHeight +
              (isWide ? DefaultTextStyle.of(context).style.fontSize * 2 : 0);
          final width = height * .75;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              HeaderWidget('Top Threads'),
              Padding(
                child: SizedBox(
                  child: ListView.builder(
                    itemBuilder: (_, i) => Padding(
                          child: _ThreadWidget(
                            _threads[i],
                            height: height,
                            isWide: isWide,
                            width: width,
                          ),
                          padding: const EdgeInsets.all(_kTopThreadPadding),
                        ),
                    itemCount: _threads.length,
                    scrollDirection: Axis.horizontal,
                  ),
                  height: height + 2 * _kTopThreadPadding,
                ),
                padding: const EdgeInsets.all(_kTopThreadPadding),
              ),
            ],
          );
        },
      );

  void _fetch() => apiGet(
        ApiCaller.stateful(this),
        'lists/7/threads?limit=15'
        '&_bdImageApiThreadThumbnailWidth=${_kTopThreadHeight.toInt()}'
        '&_bdImageApiThreadThumbnailHeight=sh',
        onSuccess: (jsonMap) {
          if (!jsonMap.containsKey('threads')) return;

          final list = jsonMap['threads'] as List;
          final threads = <Thread>[];

          for (final Map map in list) {
            final thread = Thread.fromJson(map);
            threads.add(thread);
          }

          setState(() => _threads.addAll(threads));
        },
      );
}

class _ThreadWidget extends StatelessWidget {
  final Thread thread;

  final double height;
  final bool isWide;
  final double width;

  _ThreadWidget(
    this.thread, {
    @required this.height,
    @required this.isWide,
    @required this.width,
    Key key,
  })  : assert(thread != null),
        assert(height != null),
        assert(isWide != null),
        assert(width != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _buildGestureDetector(
      context,
      _buildBox(
        context,
        thread.threadThumbnail != null
            ? Image(
                image: CachedNetworkImageProvider(thread.threadThumbnail.link),
                fit: BoxFit.cover,
              )
            : null,
        Text.rich(
          TextSpan(
            children: <TextSpan>[
              TextSpan(
                style: TextStyle(color: theme.accentColor),
                text: thread.creatorUsername,
              ),
              TextSpan(text: " ${formatNumber(thread.threadViewCount)} views")
            ],
            style: theme.textTheme.caption,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          thread.threadTitle,
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildBox(
    BuildContext context,
    Widget image,
    Widget info,
    Widget title,
  ) {
    final theme = Theme.of(context);

    final body = <Widget>[];
    if (isWide) {
      body.addAll(<Widget>[
        info,
        const SizedBox(height: 5),
      ]);
    }
    body.add(Expanded(child: title));

    return Container(
      child: ClipRRect(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 1.5,
              child: image,
            ),
            Padding(
              child: SizedBox(
                child: Column(
                  children: body,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                ),
                width: width - _kTopThreadPadding * 2,
                height: height / 2 - _kTopThreadPadding * 4,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: _kTopThreadPadding,
                vertical: _kTopThreadPadding * 2,
              ),
            ),
          ],
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        borderRadius: BorderRadius.circular(5),
      ),
      height: height,
      width: width,
    );
  }

  Widget _buildGestureDetector(BuildContext context, Widget child) =>
      GestureDetector(
        child: child,
        onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ThreadViewScreen(thread)),
            ),
      );
}

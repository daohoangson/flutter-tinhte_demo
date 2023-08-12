import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_api/thread.dart';
import 'package:the_app/src/screens/thread_view.dart';
import 'package:the_app/src/widgets/home/header.dart';
import 'package:the_app/src/widgets/super_list.dart';
import 'package:the_app/src/api.dart';
import 'package:the_app/src/intl.dart';

const _kTopThreadHeight = 200.0;
const _kTopThreadPadding = 5.0;

class TopThreadsWidget extends StatelessWidget {
  const TopThreadsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Consumer<_TopThreadsData>(
        builder: (context, data, __) {
          if (data.threads == null) {
            data.threads = [];
            _fetch(context, data);
          }
          return _build(data.threads!);
        },
      );

  Widget _build(List<Thread> threads) => LayoutBuilder(
        builder: (context, bc) {
          final isWide = bc.maxWidth > 600;
          final style = DefaultTextStyle.of(context).style;
          final fontSize = style.fontSize;
          final height = _kTopThreadHeight +
              (isWide && fontSize != null ? fontSize * 2 : 0);
          final width = height * .75;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              HeaderWidget(l(context).topThreads),
              Padding(
                padding: const EdgeInsets.all(_kTopThreadPadding),
                child: SizedBox(
                  height: height + 2 * _kTopThreadPadding,
                  child: ListView.builder(
                    itemBuilder: (_, i) => Padding(
                      padding: const EdgeInsets.all(_kTopThreadPadding),
                      child: _ThreadWidget(
                        threads[i],
                        height: height,
                        isWide: isWide,
                        width: width,
                      ),
                    ),
                    itemCount: threads.length,
                    scrollDirection: Axis.horizontal,
                  ),
                ),
              ),
            ],
          );
        },
      );

  void _fetch(BuildContext context, _TopThreadsData data) => apiGet(
        ApiCaller.stateless(context),
        'lists/7/threads?limit=15'
        '&_bdImageApiThreadThumbnailWidth=${_kTopThreadHeight.toInt()}'
        '&_bdImageApiThreadThumbnailHeight=sh',
        onSuccess: (jsonMap) {
          if (!jsonMap.containsKey('threads')) return;
          final list = jsonMap['threads'] as List;
          data.update(list.map((map) => Thread.fromJson(map)));
        },
      );

  static SuperListComplexItemRegistration registerSuperListComplexItem() {
    final data = _TopThreadsData();
    return SuperListComplexItemRegistration(
      ChangeNotifierProvider<_TopThreadsData>.value(value: data),
      clear: () => data.threads = null,
    );
  }
}

class _ThreadWidget extends StatelessWidget {
  final Thread thread;

  final double height;
  final bool isWide;
  final double width;

  const _ThreadWidget(
    this.thread, {
    required this.height,
    required this.isWide,
    required this.width,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final thumbnail = thread.threadThumbnail;
    final viewCount = thread.threadViewCount ?? 0;
    return _buildGestureDetector(
      context,
      _buildBox(
        context,
        thumbnail != null
            ? Image(
                image: CachedNetworkImageProvider(thumbnail.link),
                fit: BoxFit.cover,
              )
            : null,
        Text.rich(
          TextSpan(
            children: <TextSpan>[
              TextSpan(
                style: TextStyle(color: theme.colorScheme.secondary),
                text: thread.creatorUsername,
              ),
              if (viewCount > 0)
                TextSpan(text: " ${l(context).statsXViews(viewCount)}")
            ],
            style: theme.textTheme.bodySmall,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          thread.threadTitle ?? '',
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildBox(
    BuildContext context,
    Widget? image,
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
      decoration: BoxDecoration(
        color: theme.disabledColor,
        borderRadius: BorderRadius.circular(5),
      ),
      height: height,
      width: width,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 1.5,
              child: image,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: _kTopThreadPadding,
                vertical: _kTopThreadPadding * 2,
              ),
              child: SizedBox(
                width: width - _kTopThreadPadding * 2,
                height: height / 2 - _kTopThreadPadding * 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: body,
                ),
              ),
            ),
          ],
        ),
      ),
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

class _TopThreadsData extends ChangeNotifier {
  List<Thread>? threads;

  void update(Iterable<Thread> newThreads) {
    threads!.addAll(newThreads);
    notifyListeners();
  }
}

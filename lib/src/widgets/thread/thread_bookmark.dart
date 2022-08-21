import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:the_api/thread.dart';
import 'package:the_app/src/api.dart';
import 'package:the_app/src/config.dart';
import 'package:the_app/src/intl.dart';

class ThreadBookmarkWidget extends StatefulWidget {
  final Thread thread;

  const ThreadBookmarkWidget(this.thread, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ThreadBookmarkState();
}

class _ThreadBookmarkState extends State<ThreadBookmarkWidget> {
  bool _isBookmarking = false;

  Thread get thread => widget.thread;

  @override
  Widget build(BuildContext context) =>
      config.apiBookmarkPath?.isNotEmpty == true
          ? IconButton(
              icon: Icon(thread.threadIsBookmark
                  ? FontAwesomeIcons.solidBookmark
                  : FontAwesomeIcons.bookmark),
              onPressed: _isBookmarking
                  ? null
                  : thread.threadIsBookmark
                      ? _unbookmark
                      : _bookmark,
              tooltip: thread.threadIsBookmark
                  ? l(context).threadBookmarkUndo
                  : l(context).threadBookmark,
            )
          : const SizedBox.shrink();

  void _bookmark() => prepareForApiAction(context, () {
        if (_isBookmarking) return;
        setState(() => _isBookmarking = true);

        apiPost(
          ApiCaller.stateful(this),
          config.apiBookmarkPath!,
          bodyFields: {'thread_id': widget.thread.threadId.toString()},
          onSuccess: (_) => setState(() => thread.threadIsBookmark = true),
          onComplete: () => setState(() => _isBookmarking = false),
        );
      });

  void _unbookmark() => prepareForApiAction(context, () {
        if (_isBookmarking) return;
        setState(() => _isBookmarking = true);

        apiDelete(
          ApiCaller.stateful(this),
          config.apiBookmarkPath!,
          bodyFields: {'thread_id': widget.thread.threadId.toString()},
          onSuccess: (_) => setState(() => thread.threadIsBookmark = false),
          onComplete: () => setState(() => _isBookmarking = false),
        );
      });
}

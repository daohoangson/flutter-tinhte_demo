import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tinhte_api/thread.dart';
import 'package:the_app/src/api.dart';
import 'package:the_app/src/config.dart';
import 'package:the_app/src/intl.dart';

class ThreadBookmarkWidget extends StatefulWidget {
  final Thread thread;

  const ThreadBookmarkWidget(this.thread, {Key key})
      : assert(thread != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() => _ThreadBookmarkState();
}

class _ThreadBookmarkState extends State<ThreadBookmarkWidget> {
  bool _isBookmarking = false;

  bool get isBookmark => widget.thread.threadIsBookmark;

  set isBookmark(bool v) {
    widget.thread.threadIsBookmark = v;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) =>
      config.apiBookmarkPath?.isNotEmpty == true
          ? IconButton(
              icon: Icon(isBookmark
                  ? FontAwesomeIcons.solidBookmark
                  : FontAwesomeIcons.bookmark),
              onPressed:
                  _isBookmarking ? null : isBookmark ? _unbookmark : _bookmark,
              tooltip: isBookmark
                  ? l(context).threadBookmarkUndo
                  : l(context).threadBookmark,
            )
          : const SizedBox.shrink();

  void _bookmark() => prepareForApiAction(context, () {
        if (_isBookmarking) return;
        setState(() => _isBookmarking = true);

        apiPost(
          ApiCaller.stateful(this),
          config.apiBookmarkPath,
          bodyFields: {'thread_id': widget.thread.threadId.toString()},
          onSuccess: (_) => isBookmark = true,
          onComplete: () => setState(() => _isBookmarking = false),
        );
      });

  void _unbookmark() => prepareForApiAction(context, () {
        if (_isBookmarking) return;
        setState(() => _isBookmarking = true);

        apiDelete(
          ApiCaller.stateful(this),
          config.apiBookmarkPath,
          bodyFields: {'thread_id': widget.thread.threadId.toString()},
          onSuccess: (_) => isBookmark = false,
          onComplete: () => setState(() => _isBookmarking = false),
        );
      });
}

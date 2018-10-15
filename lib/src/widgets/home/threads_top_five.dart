import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:tinhte_api/thread.dart';

import '../../screens/thread_view.dart';
import '../thread_image.dart';

TextSpan buildThreadTextSpan(BuildContext context, Thread thread) => TextSpan(
      children: <TextSpan>[
        TextSpan(
          style: TextStyle(
            color: Theme.of(context).accentColor,
            fontWeight: FontWeight.bold,
          ),
          text: thread?.creatorUsername ?? '',
        ),
        TextSpan(text: ' • '),
        TextSpan(
          style: TextStyle(
            color: Theme.of(context).disabledColor,
          ),
          text: thread != null
              ? timeago.format(DateTime.fromMillisecondsSinceEpoch(
                  thread.threadCreateDate * 1000))
              : '',
        ),
      ],
      style: TextStyle(
        fontSize: 12.0,
      ),
    );

class ThreadsTopFiveWidget extends StatelessWidget {
  final List<Thread> threads;

  ThreadsTopFiveWidget({Key key, @required this.threads}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _buildFeatureThread(context, _getThread(0)),
        _buildOtherThread(context, _getThread(1)),
        _buildOtherThread(context, _getThread(2)),
        _buildOtherThread(context, _getThread(3)),
        _buildOtherThread(context, _getThread(4)),
      ],
    );
  }

  Widget _buildFeatureThread(BuildContext context, Thread thread) =>
      GestureDetector(
        child: Card(
          child: Column(
            children: <Widget>[
              ThreadImageWidget(image: thread?.threadImage),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  thread?.threadTitle ?? '\n\n',
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
                child: RichText(
                  text: buildThreadTextSpan(context, thread),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
        ),
        onTap: () => pushThreadViewScreen(context, thread),
      );

  Widget _buildOtherThread(BuildContext context, Thread thread) =>
      GestureDetector(
        child: Card(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                child: ThreadImageWidget(image: thread?.threadImage),
                width: MediaQuery.of(context).size.width * .4,
              ),
              Expanded(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                        thread?.threadTitle ?? '',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 5.0),
                      child: RichText(
                        text: buildThreadTextSpan(context, thread),
                      ),
                    ),
                  ],
                  crossAxisAlignment: CrossAxisAlignment.start,
                ),
              ),
            ],
          ),
        ),
        onTap: () => pushThreadViewScreen(context, thread),
      );

  Thread _getThread(int i) => i < threads.length ? threads[i] : null;
}

import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:tinhte_demo/api/model/thread.dart';
import '../thread_view.dart';
import '../../widgets/thread_image.dart';

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
                padding: const EdgeInsets.only(
                    right: 10.0, bottom: 10.0, left: 10.0),
                child: RichText(
                  text: _buildPostTextSpan(context, thread),
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
                      padding: const EdgeInsets.only(
                          right: 5.0, bottom: 5.0, left: 5.0),
                      child: RichText(
                        text: _buildPostTextSpan(context, thread),
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

  TextSpan _buildPostTextSpan(BuildContext context, Thread thread) => TextSpan(
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

  Thread _getThread(int i) => i < threads.length ? threads[i] : null;
}

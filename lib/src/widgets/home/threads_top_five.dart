import 'package:flutter/material.dart';
import 'package:tinhte_api/thread.dart';

import '../../screens/thread_view.dart';
import '../thread_image.dart';
import '../threads.dart';

class ThreadsTopFiveWidget extends StatelessWidget {
  final List<Thread> threads;

  ThreadsTopFiveWidget({Key key, @required this.threads}) : super(key: key);

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, bc) {
        final w = bc.maxWidth;
        final b = w < 600.0;
        if (b) {
          return Column(
            children: <Widget>[
              _buildFeatureThread(
                context,
                _getThread(0),
                renderIndicatorOnNoImage: true,
              ),
              _buildOtherThread(context, _getThread(1)),
              _buildOtherThread(context, _getThread(2)),
              _buildOtherThread(context, _getThread(3)),
              _buildOtherThread(context, _getThread(4)),
            ],
          );
        } else {
          return Column(
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: _buildFeatureThread(context, _getThread(0)),
                  ),
                  Expanded(
                    child: _buildFeatureThread(context, _getThread(1)),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: _buildFeatureThread(context, _getThread(2)),
                  ),
                  Expanded(
                    child: _buildFeatureThread(context, _getThread(3)),
                  ),
                  Expanded(
                    child: _buildFeatureThread(context, _getThread(4)),
                  ),
                ],
              ),
            ],
          );
        }
      });

  Widget _buildFeatureThread(BuildContext context, Thread thread,
          {bool renderIndicatorOnNoImage = false}) =>
      GestureDetector(
        child: Card(
          child: Column(
            children: <Widget>[
              ThreadImageWidget(
                image: thread?.threadImage,
                threadId: thread?.threadId,
                widgetOnNoImage: renderIndicatorOnNoImage
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : null,
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: SizedBox(
                  height: 70.0,
                  child: Text(
                    thread?.threadTitle ?? '',
                    maxLines: 3,
                    style:
                        TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
                child: SizedBox(
                  height: 15.0,
                  child: RichText(
                    text: buildThreadTextSpan(context, thread),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
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
                child: ThreadImageWidget(
                  image: thread?.threadImage,
                  threadId: thread?.threadId,
                ),
                height: 90.0,
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
                      padding: const EdgeInsets.all(5.0),
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

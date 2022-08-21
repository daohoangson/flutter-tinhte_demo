import 'package:flutter/material.dart';
import 'package:the_api/feature_page.dart';
import 'package:the_app/src/widgets/tag/fp_header.dart';
import 'package:the_app/src/widgets/threads.dart';

class FpViewScreen extends StatelessWidget {
  final FeaturePage /*!*/ fp;

  FpViewScreen(this.fp, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(fp.fullName ?? ''),
        ),
        // TODO: use better layout for fp view
        // e.g. hide thread title, show latest_posts, etc.
        body: ThreadsWidget(
          header: FpHeader(fp),
          path: "tags/${fp.tagId}",
          threadsKey: 'tagged',
        ),
      );
}

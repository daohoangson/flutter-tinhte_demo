import 'package:flutter/material.dart';
import 'package:tinhte_api/feature_page.dart';

import '../widgets/threads.dart';

pushFpViewScreen(BuildContext context, FeaturePage fp) {
  if (fp == null) return;

  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => FpViewScreen(fp)),
  );
}

class FpViewScreen extends StatelessWidget {
  final FeaturePage fp;

  FpViewScreen(this.fp, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(fp.fullName),
        ),
        // TODO: use better layout for fp view
        // e.g. hide thread title, show latest_posts, etc.
        body: ThreadsWidget(
          "tags/${fp.tagId}",
          threadsKey: 'tagged',
        ),
      );
}
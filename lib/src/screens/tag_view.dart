import 'package:flutter/material.dart';
import 'package:tinhte_api/tag.dart';

import '../widgets/tag/tag_view_header.dart';
import '../widgets/threads.dart';

class TagViewScreen extends StatelessWidget {
  final Tag tag;
  final Map initialJson;

  TagViewScreen(
    this.tag, {
    this.initialJson,
    Key key,
  })  : assert(tag != null),
        super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text("#${tag.tagText}"),
        ),
        body: ThreadsWidget(
          header: TagViewHeader(tag),
          initialJson: initialJson,
          path: tag.links?.detail ?? "tags/${tag.tagId}",
          threadsKey: 'tagged',
        ),
      );
}

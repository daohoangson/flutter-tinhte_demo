import 'package:flutter/material.dart';
import 'package:the_api/tag.dart';
import 'package:the_app/src/widgets/tag/tag_view_header.dart';
import 'package:the_app/src/widgets/threads.dart';

class TagViewScreen extends StatelessWidget {
  final Tag tag;
  final Map? initialJson;

  const TagViewScreen(
    this.tag, {
    this.initialJson,
    super.key,
  });

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

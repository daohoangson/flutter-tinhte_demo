import 'package:flutter/material.dart';

import '../../api.dart';
import '../../config.dart';
import '../../link.dart';
import '../tag/widget.dart';
import 'header.dart';

const _kTrendingTagsMax = 6;

class TrendingTagsWidget extends StatefulWidget {
  State<StatefulWidget> createState() => _TrendingTagsWidgetState();
}

class _TrendingTagsWidgetState extends State<TrendingTagsWidget> {
  final _tags = <_Tag>[];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          HeaderWidget('#trending tags'),
          Padding(
            child: LayoutBuilder(
              builder: (_, bc) => _buildGrid(bc.maxWidth > 600 ? 3 : 2),
            ),
            padding: const EdgeInsets.all(kTagWidgetPadding),
          ),
        ],
      );

  Widget _buildGrid(int cols) {
    final rows = (_kTrendingTagsMax / cols).floor();
    final widgets = <Widget>[];

    for (int row = 0; row < rows; row++) {
      final rowWidgets = <Widget>[];

      for (int col = 0; col < cols; col++) {
        final i = row * cols + col;
        final built = Expanded(
          child: _buildTagWidget(i < _tags.length ? _tags[i] : null),
        );
        rowWidgets.add(built);
      }

      widgets.add(Row(children: rowWidgets));
    }

    return Column(children: widgets);
  }

  Widget _buildTagWidget(_Tag tag) => TagWidget(
        image: tag?.tagImg,
        label: tag?.tagName != null ? "#${tag.tagName}" : null,
        onTap: tag?.tagName != null
            ? () => launchLink(
                  context,
                  "$configSiteRoot/tags?t=${Uri.encodeQueryComponent(tag.tagName)}",
                )
            : null,
      );

  void _fetch() => apiGet(
        ApiCaller.stateful(this),
        "tinhte/threads-in-trending-tags?limit=$_kTrendingTagsMax",
        onSuccess: (jsonMap) {
          if (!jsonMap.containsKey('trending_tag_threads')) return;

          final list = jsonMap['trending_tag_threads'] as List;
          final tags = <_Tag>[];

          for (final Map map in list) {
            if (!map.containsKey('tag_id')) continue;
            if (!map.containsKey('tag_img')) continue;
            if (!map.containsKey('tag_name')) continue;
            tags.add(_Tag(
              tagId: map['tag_id'],
              tagImg: map['tag_img'],
              tagName: map['tag_name'],
            ));
          }

          setState(() => _tags.addAll(tags));
        },
      );
}

class _Tag {
  final int tagId;
  final String tagImg;
  final String tagName;

  _Tag({this.tagId, this.tagImg, this.tagName});
}

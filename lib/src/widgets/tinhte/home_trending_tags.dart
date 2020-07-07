import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_app/src/widgets/home/header.dart';
import 'package:the_app/src/widgets/tag/widget.dart';
import 'package:the_app/src/widgets/super_list.dart';
import 'package:the_app/src/api.dart';
import 'package:the_app/src/link.dart';

const _kTrendingTagsMax = 6;

class TrendingTagsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext _) => LayoutBuilder(
        builder: (_, bc) => Consumer<_TrendingTagsData>(
          builder: (context, data, _) {
            if (data.tags == null) {
              data.tags = [];
              _fetch(context, data);
            }

            final cols = bc.maxWidth > 600 ? 3 : 2;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                HeaderWidget('#tag đang hot'),
                Padding(
                  child: _buildGrid(context, data.tags, cols),
                  padding: const EdgeInsets.all(kTagWidgetPadding),
                ),
              ],
            );
          },
        ),
      );

  Widget _buildGrid(BuildContext context, List<_Tag> tags, int cols) {
    final rows = (_kTrendingTagsMax / cols).floor();
    final widgets = <Widget>[];

    for (int row = 0; row < rows; row++) {
      final rowWidgets = <Widget>[];

      for (int col = 0; col < cols; col++) {
        final i = row * cols + col;
        final tag = i < tags.length ? tags[i] : null;
        final built = Expanded(
          child: Padding(
            child: _buildTagWidget(context, tag),
            padding: const EdgeInsets.all(kTagWidgetPadding),
          ),
        );
        rowWidgets.add(built);
      }

      widgets.add(Row(children: rowWidgets));
    }

    return Column(children: widgets);
  }

  Widget _buildTagWidget(BuildContext context, _Tag tag) => TagWidget(
        image: tag?.tagImg,
        label: tag?.tagName != null ? "#${tag.tagName}" : null,
        onTap: tag?.tagId != null
            ? () => parsePath('tags/${tag.tagId}', context: context)
            : null,
      );

  void _fetch(BuildContext context, _TrendingTagsData data) => apiGet(
        ApiCaller.stateless(context),
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

          data.update(tags);
        },
      );

  static SuperListComplexItemRegistration registerSuperListComplexItem() {
    final data = _TrendingTagsData();
    return SuperListComplexItemRegistration(
      ChangeNotifierProvider<_TrendingTagsData>.value(value: data),
      clear: () => data.tags = null,
    );
  }
}

class _Tag {
  final int tagId;
  final String tagImg;
  final String tagName;

  _Tag({this.tagId, this.tagImg, this.tagName});
}

class _TrendingTagsData extends ChangeNotifier {
  List<_Tag> tags;

  void update(Iterable<_Tag> newTags) {
    tags.addAll(newTags);
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import 'package:tinhte_api/feature_page.dart';

import '../../screens/search/feature_page.dart';
import '../../widgets/tag/widget.dart';
import '../../api.dart';
import 'header.dart';

class FeaturePagesWidget extends StatefulWidget {
  final List<FeaturePage> pages;

  FeaturePagesWidget(this.pages, {Key key})
      : assert(pages != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() => _FeaturePagesWidgetState();
}

class _FeaturePagesWidgetState extends State<FeaturePagesWidget> {
  List<FeaturePage> get pages => widget.pages;

  @override
  void initState() {
    super.initState();
    if (pages.isEmpty) _fetch();
  }

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            HeaderWidget('Cộng đồng'),
            Padding(
              child: LayoutBuilder(
                builder: (_, bc) =>
                    _buildGrid((bc.maxWidth / FpWidget.kPreferWidth).ceil()),
              ),
              padding: const EdgeInsets.all(kTagWidgetPadding),
            ),
            Center(
              child: FlatButton(
                child: Text('View all communities'),
                textColor: Theme.of(context).accentColor,
                onPressed: () => showSearch(
                      context: context,
                      delegate: FpSearchDelegate(pages),
                    ),
              ),
            )
          ],
        ),
      );

  Widget _buildGrid(int cols) {
    final children = <List<Widget>>[<Widget>[], <Widget>[]];

    for (int row = 0; row < children.length; row++) {
      for (int col = 0; col < cols; col++) {
        final i = row * cols + col;
        final built = Expanded(
          child: FpWidget(i < pages.length ? pages[i] : null),
        );
        children[row].add(built);
      }
    }

    return Column(
      children: <Widget>[
        Row(children: children[0]),
        Row(children: children[1]),
      ],
    );
  }

  void _fetch() => apiGet(
        ApiCaller.stateful(this),
        'feature-pages?order=promoted'
        "&_bdImageApiFeaturePageThumbnailSize=${(FpWidget.kPreferWidth * 3).toInt()}"
        '&_bdImageApiFeaturePageThumbnailMode=sh',
        onSuccess: (jsonMap) {
          if (!jsonMap.containsKey('pages')) return;

          final list = jsonMap['pages'] as List;
          final newPages = list.map((json) => FeaturePage.fromJson(json));
          if (newPages.isEmpty) return;

          setState(() => widget.pages
            ..clear()
            ..addAll(newPages));
        },
      );
}

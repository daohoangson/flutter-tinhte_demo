import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_api/feature_page.dart';
import 'package:the_app/src/screens/search/feature_page.dart';
import 'package:the_app/src/widgets/home/header.dart';
import 'package:the_app/src/widgets/tag/widget.dart';
import 'package:the_app/src/widgets/super_list.dart';
import 'package:the_app/src/api.dart';

class FeaturePagesWidget extends StatelessWidget {
  const FeaturePagesWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (_, bc) => Consumer<_FeaturePagesData>(
          builder: (context, data, __) {
            if (data.pages == null) {
              data.pages = [];
              _fetch(context, data);
            }

            final cols = (bc.maxWidth / FpWidget.kPreferWidth).ceil();

            return _build(context, data.pages!, cols);
          },
        ),
      );

  Widget _build(BuildContext context, List<FeaturePage> pages, int cols) =>
      Card(
        margin: const EdgeInsets.only(bottom: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const HeaderWidget('Cộng đồng'),
            Padding(
              padding: const EdgeInsets.all(kTagWidgetPadding),
              child: _buildGrid(pages, cols),
            ),
            Center(
              child: TextButton(
                onPressed: () => showSearch(
                  context: context,
                  delegate: FpSearchDelegate(pages),
                ),
                style: TextButton.styleFrom(
                  primary: Theme.of(context).colorScheme.secondary,
                ),
                child: const Text('Xem tất cả'),
              ),
            )
          ],
        ),
      );

  Widget _buildGrid(List<FeaturePage> pages, int cols) {
    final children = <List<Widget>>[<Widget>[], <Widget>[]];

    for (int row = 0; row < children.length; row++) {
      for (int col = 0; col < cols; col++) {
        final i = row * cols + col;
        final built = Expanded(
          child: Padding(
            padding: const EdgeInsets.all(kTagWidgetPadding),
            child: FpWidget(i < pages.length ? pages[i] : null),
          ),
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

  void _fetch(BuildContext context, _FeaturePagesData data) => apiGet(
        ApiCaller.stateless(context),
        'feature-pages?order=promoted'
        "&_bdImageApiFeaturePageThumbnailSize=${(FpWidget.kPreferWidth * 3).toInt()}"
        '&_bdImageApiFeaturePageThumbnailMode=sh',
        onSuccess: (jsonMap) {
          if (!jsonMap.containsKey('pages')) return;

          final list = jsonMap['pages'] as List;
          final pages = list.map((json) => FeaturePage.fromJson(json));
          if (pages.isNotEmpty) data.update(pages);
        },
      );

  static SuperListComplexItemRegistration registerSuperListComplexItem() {
    final data = _FeaturePagesData();
    return SuperListComplexItemRegistration(
      ChangeNotifierProvider<_FeaturePagesData>.value(value: data),
    );
  }
}

class _FeaturePagesData extends ChangeNotifier {
  List<FeaturePage>? pages;

  void update(Iterable<FeaturePage> newPages) {
    pages!.addAll(newPages);
    notifyListeners();
  }
}

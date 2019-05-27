import 'package:flutter/material.dart';
import 'package:tinhte_api/feature_page.dart';

import '../../screens/search/feature_page.dart';
import '../../widgets/feature_page.dart';
import '../../api.dart';
import 'header.dart';

const _kFeaturePageHeight = 100.0;
const _kFeaturePagesMax = 20;

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
            SizedBox(
              height: _kFeaturePageHeight * 2,
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 8,
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                ),
                scrollDirection: Axis.horizontal,
                itemBuilder: (_, i) =>
                    FpWidget(i < pages.length ? pages[i] : null),
                itemCount: pages.isEmpty
                    ? 6
                    : pages.length < _kFeaturePagesMax
                        ? pages.length
                        : _kFeaturePagesMax,
              ),
            ),
            pages.length > _kFeaturePagesMax
                ? Center(
                    child: FlatButton(
                      child: Text('View all communities'),
                      textColor: Theme.of(context).accentColor,
                      onPressed: () => showSearch(
                            context: context,
                            delegate: FpSearchDelegate(pages),
                          ),
                    ),
                  )
                : SizedBox.shrink(),
          ],
        ),
      );

  void _fetch() => apiGet(
        ApiCaller.stateful(this),
        'feature-pages?order=promoted'
        "&_bdImageApiFeaturePageThumbnailSize=${(_kFeaturePageHeight * 2).toInt()}"
        '&_bdImageApiFeaturePageThumbnailMode=sw',
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

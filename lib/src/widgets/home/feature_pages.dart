import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tinhte_api/feature_page.dart';

import '../../screens/fp_view.dart';
import '../../api.dart';
import '../../constants.dart';
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
  void didChangeDependencies() {
    super.didChangeDependencies();

    final user = ApiData.of(context).user;
    if (pages?.isNotEmpty == true) {
      final hasLinkFollow = pages.first.links?.follow?.isNotEmpty == true;
      if (hasLinkFollow == (user == null)) {
        // if no user but fp has link -> fetch
        // if has user but fp doesn't have link -> also fetch
        _fetch();
      }
    }
  }

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            HeaderWidget('Cộng đồng'),
            SizedBox(
              height: 200,
              child: GridView.count(
                childAspectRatio: 0.75,
                crossAxisSpacing: 8,
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                scrollDirection: Axis.horizontal,
                children: pages.isNotEmpty
                    ? pages.map((p) => _FpWidget(p)).toList()
                    : [
                        _FpWidget(null),
                        _FpWidget(null),
                        _FpWidget(null),
                      ],
              ),
            ),
            Center(
              child: FlatButton(
                child: Text('View all communities'),
                textColor: Theme.of(context).accentColor,
                onPressed: null,
              ),
            ),
          ],
        ),
      );

  void _fetch() => apiGet(
        this,
        'feature-pages?order=promoted&limit=20',
        onSuccess: (jsonMap) {
          if (!jsonMap.containsKey('pages')) return;

          final list = jsonMap['pages'] as List;
          final newPages = list.map((json) => FeaturePage.fromJson(json));
          if (newPages.isEmpty) return;

          setState(() => widget.pages
            ..clear()
            ..addAll(newPages.take(20)));
        },
      );
}

class _FpWidget extends StatelessWidget {
  final FeaturePage fp;

  _FpWidget(this.fp);

  @override
  Widget build(BuildContext context) => _buildGestureDetector(
        context,
        _buildBox(
          fp?.links?.image?.isNotEmpty == true
              ? Image(
                  image: CachedNetworkImageProvider(fp?.links?.image),
                  fit: BoxFit.cover,
                )
              : null,
          Padding(
            padding: const EdgeInsets.all(5),
            child: Text(
              fp?.fullName ?? '',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );

  Widget _buildBox(Widget head, Widget body) => Padding(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: kColorHomeFpBox,
            borderRadius: BorderRadius.circular(5),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: kColorHomeFpBoxShadow,
                offset: Offset(0, 1),
                blurRadius: 2,
                spreadRadius: 1.0,
              ),
            ],
          ),
          child: ClipRRect(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AspectRatio(
                  aspectRatio: 2,
                  child: head,
                ),
                Expanded(
                  child: Align(child: body, alignment: Alignment.centerLeft),
                ),
              ],
            ),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(2, 0, 2, 5),
      );

  Widget _buildGestureDetector(BuildContext context, Widget child) =>
      GestureDetector(
        child: child,
        onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => FpViewScreen(fp)),
            ),
      );
}

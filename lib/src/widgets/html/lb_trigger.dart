import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:photo_view/photo_view_gallery.dart';

class LbTrigger {
  final sources = <String>[];

  Widget buildGestureDetector(BuildContext context, int index, Widget child) =>
      GestureDetector(
        child: child,
        onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => _Screen(sources, initialPage: index),
              ),
            ),
      );

  BuildOp get buildOp => BuildOp(onWidgets: (meta, widgets) {
        final a = meta.domElement.attributes;
        final href = a.containsKey('href') ? a['href'] : null;
        if (href?.isNotEmpty != true) return null;

        final index = sources.length;
        sources.add(href);

        return widgets.length == 1
            ? buildGestureDetector(meta.context, index, widgets.first)
            : null;
      });
}

class _Screen extends StatelessWidget {
  final int initialPage;
  final PageController pageController;
  final List<String> sources;

  _Screen(this.sources, {this.initialPage = 0})
      : this.pageController = PageController(initialPage: initialPage);

  @override
  Widget build(BuildContext context) {
    final List<PhotoViewGalleryPageOptions> pageOptions = List();
    for (final source in sources) {
      pageOptions.add(PhotoViewGalleryPageOptions(
        imageProvider: CachedNetworkImageProvider(source),
      ));
    }

    return Scaffold(
      body: Dismissible(
        child: Stack(
          children: <Widget>[
            PhotoViewGallery(
              pageOptions: pageOptions,
              pageController: pageController,
            ),
            Positioned(
              bottom: 10.0,
              left: 0.0,
              right: 0.0,
              child: Text(
                'Swipe down to dismiss',
                style: Theme.of(context).primaryTextTheme.caption,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        direction: DismissDirection.down,
        key: GlobalKey(),
        onDismissed: (_) => Navigator.pop(context),
      ),
    );
  }
}
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart'
    show BuildOpOnWidgets;
import 'package:photo_view/photo_view.dart';

class LbTrigger {
  final BuildContext context;
  final List<String> sources = List();

  LbTrigger(this.context);

  Widget buildGestureDetector(int index, Widget child) => GestureDetector(
        child: child,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PhotoViewGalleryWrapper(
                    sources,
                    initialPage: index,
                  ),
            ),
          );
        },
      );

  BuildOpOnWidgets prepareBuildOpOnWidgets(String source) {
    final index = sources.length;
    sources.add(source);

    return (List<Widget> widgets) {
      if (widgets.length != 1) return widgets;

      return <Widget>[
        buildGestureDetector(index, widgets.first),
      ];
    };
  }
}

class PhotoViewGalleryWrapper extends StatelessWidget {
  final int initialPage;
  final PageController pageController;
  final List<String> sources;

  PhotoViewGalleryWrapper(this.sources, {this.initialPage = 0})
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

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../image.dart';
import '../posts.dart';

class LbTrigger {
  final sources = <String>[];
  final WidgetFactory wf;

  BuildOp _buildOp;
  BuildOp _imgOp;

  LbTrigger({this.wf});

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

  BuildOp get buildOp {
    _buildOp ??= BuildOp(
      onChild: (meta, e) =>
          e.localName == 'img' ? lazySet(null, buildOp: imgOp) : meta,
      onWidgets: (meta, widgets) {
        final a = meta.domElement.attributes;
        final src = a.containsKey('src') ? a['src'] : null;
        final href = a.containsKey('href') ? a['href'] : src;
        if (href?.isNotEmpty != true) return null;

        final h = a.containsKey('data-height') ? a['data-height'] : null;
        final p = a.containsKey('data-permalink') ? a['data-permalink'] : null;
        final w = a.containsKey('data-width') ? a['data-width'] : null;
        final height = h != null ? int.tryParse(h) : null;
        final width = w != null ? int.tryParse(w) : null;

        final index = sources.length;
        sources.add(p ?? href);

        final imgs = <_Img>[];
        for (final widget in widgets) {
          if (widget is _Img) imgs.add(widget);
        }

        if (imgs.length == 1) {
          var childHeight = 265.0 / 2;
          var childWidth = 265.0 / 2;
          if (height != null && width != null && height > 0) {
            final ratio = width / height;
            if (ratio > 1) {
              childHeight = childWidth / ratio;
            } else {
              childWidth = childHeight * ratio;
            }
          }

          return [
            wf.buildWrapable(
              buildGestureDetector(
                meta.context,
                index,
                CachedNetworkImage(
                  imageUrl: imgs.first.src,
                  fit: BoxFit.contain,
                  height: childHeight,
                  width: childWidth,
                ),
              ),
            ),
          ];
        }

        return [
          buildGestureDetector(
            meta.context,
            index,
            AttachmentImageWidget(
              height: height,
              permalink: p,
              src: src,
              width: width,
            ),
          ),
        ];
      },
    );

    return _buildOp;
  }

  BuildOp get imgOp {
    _imgOp ??= BuildOp(
      onWidgets: (meta, _) {
        final a = meta.domElement.attributes;
        final src = a.containsKey('src') ? a['src'] : null;
        if (src == null) return null;
        return [_Img(src)];
      },
    );
    return _imgOp;
  }
}

class _Img extends StatelessWidget {
  final String src;

  _Img(this.src);

  @override
  Widget build(BuildContext context) => CachedNetworkImage(
        imageUrl: src,
        fit: BoxFit.contain,
        height: kAttachmentSize,
        width: kAttachmentSize,
      );
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

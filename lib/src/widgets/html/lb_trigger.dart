part of '../html.dart';

class LbTrigger {
  final sources = <String>[];
  final captions = Map<int, String>();
  final WidgetFactory wf;

  BuildOp _buildOp;
  BuildOp _imgOp;

  LbTrigger({this.wf});

  Widget buildGestureDetector(BuildContext context, int index, Widget child) =>
      GestureDetector(
        child: child,
        onTap: () => Navigator.push(
              context,
              _SlideUpRoute(
                page: _Screen(
                  captions: captions,
                  initialPage: index,
                  sources: sources,
                ),
              ),
            ),
      );

  BuildOp get buildOp {
    _buildOp ??= BuildOp(
      onChild: (meta, e) =>
          e.localName == 'img' ? lazySet(null, buildOp: imgOp) : meta,
      onWidgets: (meta, widgets) {
        var skipOnTap = false;
        meta.styles((key, value) => key == 'LbTrigger' && value == 'skipOnTap'
            ? skipOnTap = true
            : null);

        final a = meta.domElement.attributes;
        final src = a.containsKey('src') ? a['src'] : null;
        final href = a.containsKey('href') ? a['href'] : src;
        if (href?.isNotEmpty != true) return null;

        final h = a.containsKey('data-height') ? a['data-height'] : null;
        final p = a.containsKey('data-permalink') ? a['data-permalink'] : href;
        final w = a.containsKey('data-width') ? a['data-width'] : null;
        final height = h != null ? int.tryParse(h) : null;
        final width = w != null ? int.tryParse(w) : null;

        final index = sources.length;
        sources.add(p);

        final imgs = widgets.where((w) => w is _Img);
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

          Widget thumbnail = Image(
            image: CachedNetworkImageProvider((imgs.first as _Img).src),
            fit: BoxFit.cover,
            height: childHeight,
            width: childWidth,
          );

          if (!skipOnTap) {
            thumbnail = buildGestureDetector(meta.context, index, thumbnail);
          }

          return [wf.buildWrapable(thumbnail)];
        }

        Widget full = _AttachmentImageWidget(
          height: height,
          permalink: p,
          src: src,
          width: width,
        );

        if (!skipOnTap) {
          full = buildGestureDetector(meta.context, index, full);
        }

        return [wf.buildPadding(full, const EdgeInsets.symmetric(vertical: 5))];
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

class _AttachmentImageWidget extends StatelessWidget {
  final int height;
  final String permalink;
  final String src;
  final int width;

  _AttachmentImageWidget({
    this.height,
    Key key,
    this.permalink,
    this.src,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (permalink == null) return Container();
    if (height == null || height < 1) return Container();
    if (width == null || width < 1) return Container();

    return LayoutBuilder(
      builder: (context, bc) {
        final mqd = MediaQuery.of(context);
        final imageUrl = getResizedUrl(
              apiUrl: src ?? permalink,
              boxWidth: mqd.devicePixelRatio * mqd.size.width,
              imageHeight: height,
              imageWidth: width,
            ) ??
            permalink;
        final image = CachedNetworkImageProvider(imageUrl);

        // image is large, just render it in aspect ratio
        if (bc.maxWidth < width)
          return AspectRatio(
            aspectRatio: width / height,
            child: Image(image: image, fit: BoxFit.cover),
          );

        // image is small, render with text padding for consistent look
        // put it in a wrap + limited box to prevent image from being scaled up
        return Padding(
          child: Wrap(children: <Widget>[
            Image(
              image: image,
              fit: BoxFit.contain,
              width: width.toDouble(),
              height: height.toDouble(),
            ),
          ]),
          padding: _kTextPadding.copyWith(bottom: 10),
        );
      },
    );
  }
}

class _Img extends StatelessWidget {
  final String src;

  _Img(this.src);

  @override
  Widget build(BuildContext context) => Container();
}

class _SlideUpRoute extends PageRouteBuilder {
  final Widget page;

  _SlideUpRoute({this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
        );
}

class _Screen extends StatefulWidget {
  final Decoration backgroundDecoration;
  final TextStyle captionStyle;
  final Map<int, String> captions;
  final int initialPage;
  final PageController pageController;
  final List<String> sources;

  _Screen({
    this.backgroundDecoration = const BoxDecoration(color: Colors.black),
    this.captionStyle = const TextStyle(color: Colors.white),
    this.captions,
    this.initialPage,
    this.sources,
  }) : pageController = PageController(initialPage: initialPage);

  @override
  State<StatefulWidget> createState() => _ScreenState();
}

class _ScreenState extends State<_Screen> {
  final key = GlobalKey();

  int _currentPage;

  @override
  void initState() {
    _currentPage = widget.initialPage;
    super.initState();
  }

  void onPageChanged(int page) => setState(() => _currentPage = page);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: widget.backgroundDecoration,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            Dismissible(
              child: PhotoViewGallery.builder(
                scrollPhysics: const BouncingScrollPhysics(),
                builder: _buildItem,
                itemCount: widget.sources.length,
                backgroundDecoration: widget.backgroundDecoration,
                pageController: widget.pageController,
                onPageChanged: onPageChanged,
              ),
              direction: DismissDirection.down,
              key: key,
              onDismissed: (_) => Navigator.pop(context),
            ),
            Padding(
              child: _buildCaption(_currentPage),
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 30),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCaption(int index) => Text(
        widget.captions.containsKey(index)
            ? widget.captions[index]
            : "${index + 1} of ${widget.sources.length}",
        style: widget.captionStyle,
      );

  PhotoViewGalleryPageOptions _buildItem(BuildContext context, int index) =>
      PhotoViewGalleryPageOptions(
        imageProvider: CachedNetworkImageProvider(widget.sources[index]),
      );
}

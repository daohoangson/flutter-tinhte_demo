part of '../html.dart';

class LbTrigger {
  final captions = Map<int, Widget>();
  final sources = <String>[];
  final WidgetFactory wf;

  BuildOp _fullOp;

  LbTrigger({this.wf});

  Widget buildGestureDetector(int index, Widget child) =>
      Builder(builder: (c) => buildGestureDetectorWithContext(c, index, child));

  Widget buildGestureDetectorWithContext(BuildContext c, int i, Widget child) =>
      GestureDetector(
        child: child,
        onTap: () => Navigator.push(
          c,
          _ScaleRoute(
            page: _Screen(captions: captions, initialPage: i, sources: sources),
          ),
        ),
      );

  BuildOp prepareThumbnailOp(dom.Element e) {
    final a = e.attributes;
    if (!a.containsKey('data-height') ||
        !a.containsKey('data-width') ||
        !a.containsKey('href')) return null;

    final href = a['href'];
    final url = wf.constructFullUrl(href);
    if (url == null) return null;

    final height = double.tryParse(a['data-height']);
    final width = double.tryParse(a['data-width']);
    if (height == null || width == null) return null;

    var childHeight = 265.0 / 2;
    var childWidth = 265.0 / 2;
    final ratio = width / height;
    if (ratio > 1) {
      childHeight = childWidth / ratio;
    } else {
      childWidth = childHeight * ratio;
    }

    final index = sources.length;
    sources.add(url);

    return BuildOp(
      onChild: (meta, e) {
        if (e.localName != 'img') return meta;

        return lazySet(
          meta,
          styles: [
            'height',
            "${childHeight.toString()}px",
            'width',
            "${childWidth.toString()}px",
          ],
        );
      },
      onPieces: (meta, pieces) =>
          pieces.map((piece) => piece.hasWidgets ? piece : piece
            ..block.rebuildBits(
              (b) => b is WidgetBit
                  ? b.rebuild(
                      child: buildGestureDetector(
                        index,
                        b.widgetSpan.child,
                      ),
                    )
                  : b,
            )),
    );
  }

  BuildOp get fullOp {
    _fullOp = BuildOp(
      onChild: (meta, e) {
        if (e.localName != 'img') return meta;

        final a = e.attributes;
        final href = a['src'];
        final url = wf.constructFullUrl(href);
        if (url == null) return meta;

        final index = sources.length;
        sources.add(url);

        return lazySet(
          meta,
          buildOp: BuildOp(
            onWidgets: (_, widgets) =>
                widgets.map((widget) => buildGestureDetector(index, widget)),
          ),
          styles: ['margin', '0.5em 0'],
        );
      },
    );

    return _fullOp;
  }
}

class _ScaleRoute extends PageRouteBuilder {
  final Widget page;

  _ScaleRoute({this.page})
      : super(
          pageBuilder: (_, __, ___) => page,
          transitionsBuilder: (context, animation, _, __) => ScaleTransition(
            child: page,
            scale: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.fastOutSlowIn,
              ),
            ),
          ),
        );
}

class _Screen extends StatefulWidget {
  final Map<int, Widget> captions;
  final int initialPage;
  final PageController pageController;
  final List<String> sources;

  _Screen({
    this.captions,
    this.initialPage,
    this.sources,
  }) : pageController = PageController(initialPage: initialPage);

  @override
  State<StatefulWidget> createState() => _ScreenState();
}

class _ScreenState extends State<_Screen> {
  int _currentPage;

  @override
  void initState() {
    _currentPage = widget.initialPage;
    super.initState();
  }

  void onPageChanged(int page) => setState(() => _currentPage = page);

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Stack(
          children: <Widget>[
            PhotoViewGallery.builder(
              builder: _buildItem,
              itemCount: widget.sources.length,
              loadingBuilder: (context, event) => Container(
                child: Center(
                  child: CircularProgressIndicator(
                    value: event == null
                        ? null
                        : event.cumulativeBytesLoaded /
                            event.expectedTotalBytes,
                  ),
                ),
                decoration: BoxDecoration(color: Colors.black),
              ),
              pageController: widget.pageController,
              onPageChanged: onPageChanged,
              scrollPhysics: const ClampingScrollPhysics(),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                child: _buildCaption(context, _currentPage),
                padding: const EdgeInsets.all(44),
              ),
            ),
          ],
        ),
      );

  Widget _buildCaption(BuildContext context, int index) => Column(
        children: <Widget>[
          DefaultTextStyle(
            style: TextStyle(color: Colors.white70),
            child: widget.captions.containsKey(index)
                ? widget.captions[index]
                : Text("${index + 1} of ${widget.sources.length}"),
          ),
          FlatButton(
            child: Text('OK'),
            colorBrightness: Brightness.dark,
            onPressed: () => Navigator.of(context).pop(),
          )
        ],
        mainAxisSize: MainAxisSize.min,
      );

  PhotoViewGalleryPageOptions _buildItem(BuildContext context, int index) =>
      PhotoViewGalleryPageOptions(
        imageProvider: NetworkImage(widget.sources[index]),
      );
}

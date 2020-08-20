part of '../html.dart';

const kCaptionColor = Colors.white70;

class LbTrigger {
  final captions = Map<int, Widget>();
  final hashCodes = <int>[0];
  final sources = <String>[];
  final WidgetFactory wf;

  BuildOp _fullOp;

  LbTrigger({this.wf});

  Widget buildGestureDetector(BuildContext c, Widget child, int i) =>
      GestureDetector(
        child: child,
        onTap: () => Navigator.push(
          c,
          _ScaleRoute(
            page: _Screen(captions: captions, initialPage: i, sources: sources),
          ),
        ),
      );

  BuildOp prepareThumbnailOp(Map<dynamic, String> a) {
    if (!a.containsKey('data-height') ||
        !a.containsKey('data-width') ||
        !a.containsKey('href')) return null;

    final href = a['href'];
    final url = wf.urlFull(href);
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

    return BuildOp(
      onChild: (meta) {
        if (meta.element.localName != 'img') return;

        meta
          ..['height'] = "${childHeight}px"
          ..['width'] = "${childWidth}px";
      },
      onPieces: (meta, pieces) {
        final index = _addSource(url);

        for (final piece in pieces) {
          if (piece.widgets != null) continue;
          for (final bit in piece.text.bits) {
            if (bit is TextWidget) {
              bit.child.wrapWith((c, w) => buildGestureDetector(c, w, index));
            }
          }
        }
        return pieces;
      },
    );
  }

  BuildOp prepareXenForo2Op(Map<dynamic, String> attrs, String key) {
    final url = wf.urlFull(attrs.containsKey(key) ? attrs[key] : null);
    if (url == null) return null;

    final index = _addSource(url);

    return BuildOp(
      isBlockElement: false,
      onPieces: (meta, pieces) {
        if (meta.isBlockElement) return pieces;

        for (final piece in pieces) {
          if (piece.text == null) continue;
          for (final bit in piece.text.bits) {
            if (bit is TextWidget) {
              bit.child.wrapWith((c, w) => buildGestureDetector(c, w, index));
            }
          }
        }

        return pieces;
      },
      onWidgets: (meta, widgets) {
        final column = wf.buildColumnPlaceholder(meta, widgets)
          ..wrapWith((c, w) => buildGestureDetector(c, w, index));
        return column != null ? [column] : widgets;
      },
      priority: 9999,
    );
  }

  BuildOp get fullOp {
    _fullOp = BuildOp(
      onChild: (meta) {
        if (meta.element.localName != 'img') return;

        final a = meta.element.attributes;
        final href = a['src'];
        final url = wf.urlFull(href);
        if (url == null) return;

        final index = _addSource(url);
        meta
          ..['margin'] = '0.5em 0'
          ..register(BuildOp(onWidgets: (_, widgets) {
            for (final widget in widgets) {
              widget.wrapWith((c, w) => buildGestureDetector(c, w, index));
            }
            return widgets;
          }));
      },
    );

    return _fullOp;
  }

  int _addSource(String source) {
    final index = sources.length;
    sources.add(source);

    return index;
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
          widget.captions.containsKey(index)
              ? widget.captions[index]
              : Text(
                  l(context).navXOfY(index + 1, widget.sources.length),
                  style: Theme.of(context)
                      .textTheme
                      .caption
                      .copyWith(color: kCaptionColor),
                ),
          FlatButton(
            child: Text(lm(context).okButtonLabel),
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

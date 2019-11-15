part of '../html.dart';

class LbTrigger {
  final captions = Map<int, Widget>();
  final sources = <String>[];
  final WidgetFactory wf;

  BuildOp _buildOp;

  LbTrigger({this.wf});

  Widget buildGestureDetector(int index, Widget child) =>
      Builder(builder: (c) => buildGestureDetectorWithContext(c, index, child));

  Widget buildGestureDetectorWithContext(BuildContext c, int i, Widget child) =>
      GestureDetector(
        child: child,
        onTap: () => Navigator.push(
          c,
          _SlideUpRoute(
            page: _Screen(captions: captions, initialPage: i, sources: sources),
          ),
        ),
      );

  BuildOp prepareBuildOpForATag(NodeMetadata meta, dom.Element e) {
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

  BuildOp get buildOp {
    _buildOp ??= BuildOp(
      onChild: (meta, e) {
        if (e.localName != 'img') return meta;

        return lazySet(
          meta,
          isBlockElement: true,
          styles: ['margin', '0.5em 0'],
        );
      },
    );

    return _buildOp;
  }
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
  final Map<int, Widget> captions;
  final int initialPage;
  final PageController pageController;
  final List<String> sources;

  _Screen({
    this.backgroundDecoration = const BoxDecoration(color: Colors.black),
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
  Widget build(BuildContext context) => Dismissible(
        child: Scaffold(
          body: Container(
            decoration: widget.backgroundDecoration,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: <Widget>[
                PhotoViewGallery.builder(
                  scrollPhysics: const BouncingScrollPhysics(),
                  builder: _buildItem,
                  itemCount: widget.sources.length,
                  backgroundDecoration: widget.backgroundDecoration,
                  pageController: widget.pageController,
                  onPageChanged: onPageChanged,
                ),
                Padding(
                  child: _buildCaption(context, _currentPage),
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 30),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: InkWell(
                    child: SafeArea(
                      child: Padding(
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                        padding: const EdgeInsets.all(10),
                      ),
                    ),
                    onTap: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
        ),
        direction: DismissDirection.down,
        key: key,
        onDismissed: (_) => Navigator.pop(context),
        resizeDuration: null,
      );

  Widget _buildCaption(BuildContext context, int index) => DefaultTextStyle(
        style: TextStyle(color: Colors.white70),
        child: widget.captions.containsKey(index)
            ? widget.captions[index]
            : Text("${index + 1} of ${widget.sources.length}"),
      );

  PhotoViewGalleryPageOptions _buildItem(BuildContext context, int index) =>
      PhotoViewGalleryPageOptions(
        imageProvider: CachedNetworkImageProvider(widget.sources[index]),
      );
}

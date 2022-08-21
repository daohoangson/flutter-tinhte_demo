part of '../html.dart';

const kCaptionColor = Colors.white70;

class LbTrigger {
  final hashCodes = <int>[0];
  final WidgetFactory? wf;

  final _captions = Map<int, Widget>();
  final _sources = <LbTriggerSource>[];

  BuildOp? _fullOp;

  LbTrigger({this.wf});

  Widget buildGestureDetector(BuildContext c, Widget child, int i) =>
      GestureDetector(
        child: child,
        onTap: () => Navigator.push(
          c,
          _ScaleRoute(
            _Screen(
              captions: _captions,
              initialPage: i,
              sources: _sources,
            ),
          ),
        ),
      );

  BuildOp? prepareThumbnailOp(Map<Object, String > a) {
    final url = wf?.urlFull(a['href'] ?? '');
    if (url == null) return null;

    final height = double.tryParse(a['data-height'] ?? '');
    final width = double.tryParse(a['data-width'] ?? '');
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
      onTree: (meta, tree) {
        final index = addSource(LbTriggerSource.image(url));

        for (final bit in tree.bits) {
          if (bit is WidgetBit) {
            bit.child.wrapWith((c, w) => buildGestureDetector(c, w, index));
          }
        }
      },
    );
  }

  BuildOp get fullOp {
    return _fullOp ??= BuildOp(
      onChild: (meta) {
        if (meta.element.localName != 'img') return;

        final a = meta.element.attributes;
        final url = wf?.urlFull(a['src'] ?? '');
        if (url == null) return;

        final index = addSource(LbTriggerSource.image(url));
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
  }

  int addSource(LbTriggerSource source, {Widget? caption}) {
    final index = _sources.length;
    _sources.add(source);

    if (caption != null) {
      _captions[index] = caption;
    }

    return index;
  }
}

abstract class LbTriggerSource {
  String get url;

  factory LbTriggerSource.image(String url) = _LbTriggerImage;
  factory LbTriggerSource.video(String url, {double aspectRatio}) =
      _LbTriggerVideo;

  const LbTriggerSource._();
}

class _LbTriggerImage extends LbTriggerSource {
  @override
  final String url;

  _LbTriggerImage(this.url) : super._();
}

class _LbTriggerVideo extends LbTriggerSource {
  final double aspectRatio;

  @override
  final String url;

  _LbTriggerVideo(this.url, {required this.aspectRatio}) : super._();
}

class _ScaleRoute extends PageRouteBuilder {
  final Widget page;

  _ScaleRoute(this.page)
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
  final List<LbTriggerSource> sources;

  _Screen({
    required this.captions,
    required this.initialPage,
    required this.sources,
  }) : pageController = PageController(initialPage: initialPage);

  @override
  State<StatefulWidget> createState() => _ScreenState();
}

class _ScreenState extends State<_Screen> {
  late int _currentPage;

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
              loadingBuilder: (context, event) {
                final loaded = event?.cumulativeBytesLoaded ?? 0;
                final total = event?.expectedTotalBytes ?? 0;
                return Container(
                  child: Center(
                    child: CircularProgressIndicator(
                      value: total == 0 ? null : loaded / total,
                    ),
                  ),
                  decoration: BoxDecoration(color: Colors.black),
                );
              },
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

  Widget _buildCaption(BuildContext context, int index) {
    final caption = widget.captions[index];
    return Column(
      children: <Widget>[
        caption != null
            ? DefaultTextStyle(
                child: caption,
                style: TextStyle(color: kCaptionColor),
              )
            : Text(
                l(context).navXOfY(index + 1, widget.sources.length),
                style: Theme.of(context)
                    .textTheme
                    .caption
                    ?.copyWith(color: kCaptionColor),
              ),
        TextButton(
          child: Text(lm(context).okButtonLabel),
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(primary: kCaptionColor),
        )
      ],
      mainAxisSize: MainAxisSize.min,
    );
  }

  PhotoViewGalleryPageOptions _buildItem(BuildContext context, int index) {
    final source = widget.sources[index];

    if (source is _LbTriggerImage) {
      return PhotoViewGalleryPageOptions(
        imageProvider: NetworkImage(source.url),
      );
    }

    Widget child = const SizedBox.shrink();
    if (source is _LbTriggerVideo) {
      child = VideoPlayer(
        aspectRatio: source.aspectRatio,
        autoPlay: true,
        url: source.url,
      );
    }

    return PhotoViewGalleryPageOptions.customChild(child: child);
  }
}

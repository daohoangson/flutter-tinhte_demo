part of '../html.dart';

class PhotoCompare {
  final TinhteWidgetFactory wf;

  PhotoCompare(this.wf);

  BuildOp get buildOp {
    final images = <String>[];
    return BuildOp(
      onChild: (meta, e) {
        if (e.localName != 'img') return meta;
        if (!e.attributes.containsKey('src')) return meta;
        final src = wf.constructFullUrl(e.attributes['src']);
        if (src != null) images.add(src);

        return meta;
      },
      onWidgets: (meta, widgets) {
        if (images.length != 2) return widgets;

        final a = meta.domElement.attributes;
        if (!a.containsKey('data-config')) return widgets;

        final Map config = json.decode(a['data-config']);
        if (!config.containsKey('width') ||
            !(config['width'] is num) ||
            !config.containsKey('height') ||
            !(config['height'] is num)) return widgets;

        final width = (config['width'] as num).toDouble();
        final height = (config['height'] as num).toDouble();

        return [
          _buildSpacing(meta),
          _PhotoCompareWidget(
            aspectRatio: width / height,
            image0: wf.buildImage(images.first, height: height, width: width),
            image1: wf.buildImage(images.last, height: height, width: width),
          ),
          _buildSpacing(meta),
        ];
      },
    );
  }
}

class _PhotoCompareWidget extends StatefulWidget {
  final double aspectRatio;
  final Widget image0;
  final Widget image1;

  _PhotoCompareWidget({
    this.aspectRatio,
    this.image0,
    this.image1,
  })  : assert(aspectRatio != null),
        assert(image0 != null),
        assert(image1 != null);

  @override
  _PhotoCompareState createState() => _PhotoCompareState();
}

class _PhotoCompareState extends State<_PhotoCompareWidget> {
  double position = _PhotoCompareHandler.positionZero;

  Widget build(BuildContext context) {
    final widgets = <Widget>[
      _buildAspectRatio(widget.image0),
      Align(
        alignment: Alignment.topRight,
        child: ClipRect(
          child: Align(
            alignment: Alignment.topRight,
            widthFactor: 1 - position,
            child: _buildAspectRatio(widget.image1),
          ),
        ),
      ),
    ];

    if (position == _PhotoCompareHandler.positionZero) {
      widgets.add(Positioned.fill(child: _PhotoCompareHandler()));
    }

    return GestureDetector(
      onHorizontalDragDown: (details) =>
          _updatePosition(context, details.localPosition),
      onHorizontalDragUpdate: (details) =>
          _updatePosition(context, details.localPosition),
      child: Stack(children: widgets),
    );
  }

  Widget _buildAspectRatio(Widget child) => widget.aspectRatio != null
      ? AspectRatio(aspectRatio: widget.aspectRatio, child: child)
      : child;

  void _updatePosition(BuildContext context, Offset offset) => setState(() =>
      position = offset.dx / context.findRenderObject().paintBounds.width);
}

class _PhotoCompareHandler extends StatefulWidget {
  static const boxSize = 1.4 * iconSize;
  static const iconSize = 30.0;
  static const color = Colors.white70;
  static const positionZero = .5;

  @override
  _PhotoCompareHandlerState createState() => _PhotoCompareHandlerState();
}

class _PhotoCompareHandlerState extends State<_PhotoCompareHandler>
    with TickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
        children: <Widget>[
          Center(child: _PhotoCompareAnimation(_controller.view)),
          Center(
            child: Container(
              height: _PhotoCompareHandler.boxSize,
              width: _PhotoCompareHandler.boxSize,
              decoration: BoxDecoration(
                border: Border.all(color: _PhotoCompareHandler.color, width: 2),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      );
}

class _PhotoCompareAnimation extends StatelessWidget {
  final Animation<double> controller;
  final Animation<double> width;

  _PhotoCompareAnimation(this.controller)
      : width = Tween<double>(begin: 1.4, end: 1.7).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(0.0, 0.5, curve: Curves.ease),
          ),
        );

  @override
  Widget build(BuildContext _) =>
      AnimatedBuilder(builder: _buildAnimation, animation: controller);

  Widget _buildAnimation(BuildContext _, Widget __) => SizedBox(
        child: Stack(
          children: <Widget>[
            _buildIcon(Icons.chevron_left),
            Positioned(
              right: 0,
              child: _buildIcon(Icons.chevron_right),
            )
          ],
        ),
        width: width.value * _PhotoCompareHandler.iconSize,
      );

  Widget _buildIcon(IconData icon) => Icon(
        icon,
        color: _PhotoCompareHandler.color,
        size: _PhotoCompareHandler.iconSize,
      );
}

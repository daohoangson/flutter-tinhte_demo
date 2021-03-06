part of '../html.dart';

class PhotoCompare {
  final TinhteWidgetFactory wf;

  PhotoCompare(this.wf);

  BuildOp get buildOp => BuildOp(
        defaultStyles: (_) => {'margin': '0.5em 0'},
        onChild: (childMeta) {
          if (childMeta.element.localName == 'img') {
            childMeta['display'] = 'block';
          }
        },
        onWidgets: (meta, widgets) {
          final images = <Widget>[];
          for (final widget in widgets) {
            if (widget is WidgetPlaceholder<ImageMetadata>) {
              images.add(widget);
            }
          }

          if (images.length != 2) return widgets;

          final a = meta.element.attributes;
          if (!a.containsKey('data-config')) return widgets;

          final Map config = json.decode(a['data-config']);
          if (!config.containsKey('width') ||
              (config['width'] is! num) ||
              !config.containsKey('height') ||
              (config['height'] is! num)) return widgets;

          final width = (config['width'] as num).toDouble();
          final height = (config['height'] as num).toDouble();

          return [
            _PhotoCompareWidget(
              aspectRatio: width / height,
              image0: images[0],
              image1: images[1],
            ),
          ];
        },
      );
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
      Positioned.fill(
        child: FractionallySizedBox(
          alignment: Alignment.topLeft,
          child: Stack(
            children: <Widget>[
              Positioned(
                bottom: 0,
                child: Container(
                  color: _PhotoCompareHandler.color,
                  width: _PhotoCompareHandler.dividerSize,
                ),
                right: _PhotoCompareHandler.dividerSize / -2,
                top: 0,
              ),
              Positioned(
                bottom: 0,
                child: _PhotoCompareHandler(
                    animate: position == _PhotoCompareHandler.positionZero),
                right: _PhotoCompareHandler.boxSize / -2,
                top: 0,
              ),
            ],
            clipBehavior: Clip.none,
          ),
          widthFactor: position,
        ),
      ),
    ];

    return GestureDetector(
      // onHorizontalDragDown: (details) =>
      //     _updatePosition(context, details.localPosition),
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
  static const dividerSize = 2.0;
  static const iconSize = 30.0;
  static const color = Colors.white70;
  static const positionZero = .5;

  final bool animate;

  const _PhotoCompareHandler({Key key, this.animate}) : super(key: key);

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

  void didUpdateWidget(_PhotoCompareHandler old) {
    super.didUpdateWidget(old);

    if (widget.animate != old.animate && !widget.animate) {
      _controller.stop();
    }
  }

  @override
  Widget build(BuildContext context) => Container(
        child: _PhotoCompareAnimation(_controller.view),
        decoration: BoxDecoration(
          border: Border.all(color: _PhotoCompareHandler.color, width: 2),
          shape: BoxShape.circle,
        ),
        height: _PhotoCompareHandler.boxSize,
        width: _PhotoCompareHandler.boxSize,
      );
}

class _PhotoCompareAnimation extends StatelessWidget {
  final Animation<double> controller;
  final Animation<double> offset;

  _PhotoCompareAnimation(this.controller)
      : offset = Tween<double>(begin: -.4, end: -.7).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(0, .5, curve: Curves.ease),
          ),
        );

  @override
  Widget build(BuildContext _) =>
      AnimatedBuilder(builder: _buildAnimation, animation: controller);

  Widget _buildAnimation(BuildContext _, Widget __) => Stack(
        children: <Widget>[
          Positioned.fill(
            left: offset.value * _PhotoCompareHandler.iconSize,
            child: _buildIcon(Icons.chevron_left),
          ),
          Positioned.fill(
            right: offset.value * _PhotoCompareHandler.iconSize,
            child: _buildIcon(Icons.chevron_right),
          )
        ],
      );

  Widget _buildIcon(IconData icon) => Icon(
        icon,
        color: _PhotoCompareHandler.color,
        size: _PhotoCompareHandler.iconSize,
      );
}

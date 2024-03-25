part of '../html.dart';

class PhotoCompare {
  @visibleForTesting
  static var debugDeterministicHandler = false;

  final TinhteWidgetFactory wf;

  PhotoCompare(this.wf);

  BuildOp get buildOp => BuildOp(
        defaultStyles: (_) => {'margin': '0.5em 0'},
        onVisitChild: (tree, subTree) {
          if (subTree.element.localName == 'img') {
            subTree.register(
              BuildOp(
                onRenderBlock: (_, placeholder) {
                  final value = tree.getNonInherited<_Images>();
                  if (value == null) {
                    tree.setNonInherited(_Images([placeholder]));
                  } else {
                    value.widgets.add(placeholder);
                  }
                  return widget0;
                },
                priority: Priority.tagImg + 1,
              ),
            );
          }
        },
        onParsed: (tree) {
          final replacement = tree.parent.sub();
          final images = tree.getNonInherited<_Images>()?.widgets;
          if (images == null || images.length != 2) return tree;

          final a = tree.element.attributes;
          final configJson = a['data-config'] ?? '';
          if (configJson.isEmpty) return tree;

          final Map config = json.decode(configJson);
          final width = (config['width'] as num?)?.toDouble();
          final height = (config['height'] as num?)?.toDouble();
          if (width == null || height == null) return tree;

          return replacement
            ..append(
              WidgetBit.block(
                tree.parent,
                _PhotoCompareWidget(
                  aspectRatio: width / height,
                  image0: images[0],
                  image1: images[1],
                ),
              ),
            );
        },
      );
}

class _Images {
  final List<Widget> widgets;
  const _Images(this.widgets);
}

class _PhotoCompareWidget extends StatefulWidget {
  final double aspectRatio;
  final Widget image0;
  final Widget image1;

  const _PhotoCompareWidget({
    required this.aspectRatio,
    required this.image0,
    required this.image1,
  });

  @override
  _PhotoCompareState createState() => _PhotoCompareState();
}

class _PhotoCompareState extends State<_PhotoCompareWidget> {
  double position = _PhotoCompareHandler.positionZero;

  @override
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
          widthFactor: position,
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Positioned(
                bottom: 0,
                right: _PhotoCompareHandler.dividerSize / -2,
                top: 0,
                child: Container(
                  color: _PhotoCompareHandler.color,
                  width: _PhotoCompareHandler.dividerSize,
                ),
              ),
              Positioned(
                bottom: 0,
                right: _PhotoCompareHandler.boxSize / -2,
                top: 0,
                child: _PhotoCompareHandler(
                    animate: position == _PhotoCompareHandler.positionZero),
              ),
            ],
          ),
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

  Widget _buildAspectRatio(Widget child) => AspectRatio(
        aspectRatio: widget.aspectRatio,
        child: child,
      );

  void _updatePosition(BuildContext context, Offset offset) {
    final renderObject = context.findRenderObject();
    if (renderObject == null) return;

    setState(() => position = offset.dx / renderObject.paintBounds.width);
  }
}

class _PhotoCompareHandler extends StatefulWidget {
  static const boxSize = 1.4 * iconSize;
  static const dividerSize = 2.0;
  static const iconSize = 30.0;
  static const color = Colors.white70;
  static const positionZero = .5;

  final bool animate;

  const _PhotoCompareHandler({required this.animate});

  @override
  _PhotoCompareHandlerState createState() => _PhotoCompareHandlerState();
}

class _PhotoCompareHandlerState extends State<_PhotoCompareHandler>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    if (!PhotoCompare.debugDeterministicHandler) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_PhotoCompareHandler old) {
    super.didUpdateWidget(old);

    if (widget.animate != old.animate && !widget.animate) {
      _controller.stop();
    }
  }

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          border: Border.all(color: _PhotoCompareHandler.color, width: 2),
          shape: BoxShape.circle,
        ),
        height: _PhotoCompareHandler.boxSize,
        width: _PhotoCompareHandler.boxSize,
        child: _PhotoCompareAnimation(_controller.view),
      );
}

class _PhotoCompareAnimation extends StatelessWidget {
  final Animation<double> controller;
  final Animation<double> offset;

  _PhotoCompareAnimation(this.controller)
      : offset = Tween<double>(begin: -.4, end: -.7).animate(
          CurvedAnimation(
            parent: controller,
            curve: const Interval(0, .5, curve: Curves.ease),
          ),
        );

  @override
  Widget build(BuildContext context) =>
      AnimatedBuilder(builder: _buildAnimation, animation: controller);

  Widget _buildAnimation(BuildContext context, Widget? __) => Stack(
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

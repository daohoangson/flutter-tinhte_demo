part of '../html.dart';

class PhotoCompare {
  final TinhteWidgetFactory wf;

  BuildOp _buildOp;

  PhotoCompare(this.wf);

  BuildOp get buildOp {
    _buildOp ??= BuildOp(
      onChild: (meta, e) =>
          e.localName == 'img' ? lazySet(meta, isBlockElement: true) : meta,
      onWidgets: (meta, widgets) {
        final images = widgets.where((w) => w is core.ImageLayout);
        if (images.length != 2) return null;

        final widget0 = images.first as core.ImageLayout;
        final widget1 = images.last as core.ImageLayout;
        if (widget0.height == null ||
            widget0.width == null ||
            widget0.height == 0) return null;

        return [
          _PhotoCompareWidget(
            aspectRatio: widget0.width / widget0.height,
            image0: widget0.image,
            image1: widget1.image,
          ),
        ];
      },
    );

    return _buildOp;
  }
}

class _PhotoCompareWidget extends StatefulWidget {
  final double aspectRatio;
  final ImageProvider image0;
  final ImageProvider image1;

  _PhotoCompareWidget({
    this.aspectRatio,
    this.image0,
    this.image1,
  });

  @override
  State<StatefulWidget> createState() => _PhotoCompareState();
}

class _PhotoCompareState extends State<_PhotoCompareWidget>
    with TickerProviderStateMixin {
  AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      duration: Duration(milliseconds: 100),
      vsync: this,
    );
    controller.value = .5;
  }

  @override
  Widget build(BuildContext context) => Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              AspectRatio(
                aspectRatio: widget.aspectRatio,
                child: Image(image: widget.image0),
              ),
              AnimatedBuilder(
                animation: controller,
                // TODO: avoid using ClipRect
                builder: (_, __) => ClipRect(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: AspectRatio(
                      aspectRatio: widget.aspectRatio,
                      child: Image(image: widget.image1),
                    ),
                    widthFactor: controller.value,
                  ),
                ),
              ),
            ],
          ),
          AnimatedBuilder(
            animation: controller,
            builder: (_, __) => Slider(
              value: controller.value,
              onChanged: (v) =>
                  controller.animateTo(v, curve: Curves.easeInOut),
            ),
          ),
        ],
        crossAxisAlignment: CrossAxisAlignment.stretch,
      );
}

part of '../html.dart';

class PhotoCompare {
  final TinhteWidgetFactory wf;

  BuildOp _buildOp;
  BuildOp _imgOp;

  PhotoCompare(this.wf);

  BuildOp get buildOp {
    _buildOp ??= BuildOp(
      onChild: (meta, e) =>
          e.localName == 'img' ? lazySet(meta, buildOp: imgOp) : meta,
      onWidgets: (meta, widgets) => widgets.length == 2
          ? [
              _PhotoCompareWidget(
                _noPadding(widgets.first),
                _noPadding(widgets.last),
              ),
            ]
          : null,
    );

    return _buildOp;
  }

  BuildOp get imgOp {
    _imgOp ??= BuildOp(
      defaultStyles: (_, __) => ['LbTrigger', 'skipOnTap'],
    );
    return _imgOp;
  }
}

class _PhotoCompareWidget extends StatefulWidget {
  final Widget first;
  final Widget second;

  _PhotoCompareWidget(this.first, this.second);

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
              widget.second,
              AnimatedBuilder(
                animation: controller,
                // TODO: avoid using ClipRect
                builder: (_, __) => ClipRect(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: widget.first,
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

Widget _noPadding(Widget w) => w is Padding ? w.child : w;

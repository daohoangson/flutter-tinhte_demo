part of '../html.dart';

class Unfurl {
  final NodeMetadata unfurlMeta;
  final TinhteWidgetFactory wf;

  WidgetPlaceholder _figure;
  WidgetPlaceholder _main;

  Unfurl(this.wf, this.unfurlMeta);

  BuildOp _unfurlOp;
  BuildOp get op {
    _unfurlOp ??= BuildOp(
      defaultStyles: (_) => {'margin': '0.5em 0'},
      onChild: onChild,
      onWidgets: onWidgets,
    );
    return _unfurlOp;
  }

  void onChild(NodeMetadata childMeta) {
    final e = childMeta.domElement;
    switch (e.localName) {
      case 'div':
        if (e.classes.contains('contentRow-figure')) {
          childMeta
            ..['margin-inline-start'] = '0.5em'
            ..['padding'] = '0.5em 0'
            ..['width'] = '60px'
            ..register(BuildOp(
              onChild: (childMeta) {
                if (childMeta.domElement.localName == 'img') {
                  childMeta.isBlockElement = true;
                }
              },
              onWidgets: (meta, widgets) {
                _figure = wf.buildColumnPlaceholder(meta, widgets);
                return [_figure];
              },
            ));
        } else if (e.classes.contains('contentRow-main')) {
          childMeta
            ..['padding'] = '0.5em 0'
            ..register(BuildOp(onWidgets: (meta, widgets) {
              _main = wf.buildColumnPlaceholder(meta, widgets);
              return [_main];
            }));
        } else if (e.classes.contains('contentRow-minor')) {
          childMeta
            ..register(BuildOp(onChild: (childMeta) {
              if (childMeta.domElement.localName == 'img') {
                childMeta['width'] = '1em';
              }
            }))
            ..tsb((p, _) => p.copyWith(
                style: p
                    .getDependency<ThemeData>()
                    .textTheme
                    .caption
                    .copyWith(fontSize: 12)));
        }
        break;
      case 'h3':
        childMeta
          ..['margin'] = '0.2em 0'
          ..['max-lines'] = '1'
          ..['text-overflow'] = 'ellipsis';
        break;
    }
  }

  Iterable<Widget> onWidgets(NodeMetadata _, Iterable<WidgetPlaceholder> __) =>
      _main != null
          ? [_figure != null ? _buildWithFigure() : _buildMainOnly()]
          : [];

  Widget _buildBox(Widget child) {
    final attrs = unfurlMeta.domElement.attributes;
    final url = attrs.containsKey('data-url') ? attrs['data-url'] : null;
    final fullUrl = wf.urlFull(url) ?? url;
    final onTap = wf.gestureTapCallback(fullUrl);

    return WidgetPlaceholder<Unfurl>(this)
      ..wrapWith((context, _) {
        final tsh = unfurlMeta.tsb().build(context);
        final isLtr = tsh.textDirection == TextDirection.ltr;
        final theme = Theme.of(context);
        final border = BorderSide(
          color: theme.accentColor,
          width: 2.0,
        );

        Widget built = Container(
          child: child,
          decoration: BoxDecoration(
            border: Border(
              left: isLtr ? border : BorderSide.none,
              right: isLtr ? BorderSide.none : border,
            ),
            color: theme.secondaryHeaderColor,
          ),
        );

        built = wf.buildGestureDetector(unfurlMeta, built, onTap);

        return built;
      });
  }

  Widget _buildMainOnly() => _buildBox(_main);

  Widget _buildWithFigure() => _buildBox(
        Row(
          children: [
            _figure,
            Expanded(child: _main),
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
      );
}

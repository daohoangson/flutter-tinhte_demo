part of '../html.dart';

const kLinkExpanderSquareThumbnailSize = 120.0;

class LinkExpander {
  final BuildMetadata linkMeta;
  final TinhteWidgetFactory wf;

  WidgetPlaceholder _info;
  bool _isCover;
  WidgetPlaceholder _thumbnail;

  LinkExpander(this.wf, this.linkMeta);

  BuildOp _leOp;
  BuildOp get op {
    _leOp ??= BuildOp(
      defaultStyles: (_) => {'margin': '0.5em 0'},
      onChild: onChild,
      onWidgets: onWidgets,
    );
    return _leOp;
  }

  void onChild(BuildMetadata childMeta) {
    final e = childMeta.element;
    switch (e.localName) {
      case 'div':
        if (e.classes.contains('thumbnail')) {
          _isCover = e.classes.contains('thumbnail-cover');

          childMeta.register(BuildOp(onWidgets: (meta, widgets) {
            _thumbnail = wf.buildColumnPlaceholder(meta, widgets);
            return [_thumbnail];
          }));
        } else if (e.classes.contains('info')) {
          childMeta
            ..['text-align'] = 'left'
            ..register(_LinkExpanderInfo(wf, this, childMeta).op);
        }
        break;
      case 'img':
        childMeta['display'] = 'block';
        break;
      case 'span':
        if (e.classes.contains('host')) {
          childMeta.tsb((p, _) =>
              p.copyWith(style: p.style.copyWith(color: Colors.grey)));
        }
        break;
    }
  }

  Iterable<Widget> onWidgets(BuildMetadata _, Iterable<WidgetPlaceholder> __) =>
      _thumbnail != null && _info != null
          ? [_isCover != false ? _buildCover() : _buildSquare()]
          : [];

  Widget _buildBox(BuildMetadata meta, Widget child, {double width}) {
    final a = meta.element.attributes;
    final href = a.containsKey('href') ? a['href'] : null;
    final fullUrl = wf.urlFull(href) ?? href;
    final onTap = wf.gestureTapCallback(fullUrl);

    return WidgetPlaceholder<LinkExpander>(this)
      ..wrapWith((context, _) {
        Widget built = wf.buildDecoratedBox(meta, child,
            color: Theme.of(context).cardColor);

        if (width != null) {
          built = CssSizing(
            child: built,
            maxWidth: CssSizingValue.value(width),
            minWidth: CssSizingValue.value(width),
          );
        }

        built = wf.buildGestureDetector(meta, built, onTap);

        return built;
      });
  }

  Widget _buildSquare() => _buildBox(
        linkMeta,
        LayoutBuilder(
          builder: (_, bc) {
            if (bc.maxWidth < 480) return _info;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _thumbnail,
                Expanded(
                  child: SizedBox(
                    height: kLinkExpanderSquareThumbnailSize,
                    child: _info,
                  ),
                ),
              ],
            );
          },
        ),
      );

  Widget _buildCover() => _buildBox(
        linkMeta,
        Column(
          children: <Widget>[
            _thumbnail ?? Container(),
            _info,
          ],
        ),
        width: 480,
      );

  static BuildOp _oembedOp;
  static BuildOp getOembedOp() {
    _oembedOp ??= BuildOp(
      defaultStyles: (_) => {'margin': '0.5em 0'},
      onWidgets: (meta, _) => [_buildOembedWebView(meta.element.outerHtml)],
    );
    return _oembedOp;
  }

  static Widget _buildOembedWebView(String html) {
    html = html.replaceAll('src="//', 'src="https://');
    html = """<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width">
</head>
<body style="margin:0">$html</body>
</html>""";

    return WebView(
      Uri.dataFromString(
        html,
        mimeType: 'text/html',
        encoding: Encoding.getByName('utf-8'),
      ).toString(),
      aspectRatio: 16 / 9,
      autoResize: true,
    );
  }
}

class _LinkExpanderInfo {
  final BuildMetadata infoMeta;
  final LinkExpander le;
  final TinhteWidgetFactory wf;

  Widget _description;
  BuildOp _descriptionOp;

  _LinkExpanderInfo(this.wf, this.le, this.infoMeta);

  BuildOp _infoOp;
  BuildOp get op {
    _infoOp ??= BuildOp(
      onChild: onChild,
      onWidgets: onWidgets,
    );
    return _infoOp;
  }

  void onChild(BuildMetadata childMeta) {
    if (childMeta.element.parent != infoMeta.element) return;

    switch (childMeta.element.className) {
      case 'title':
        childMeta
          ..['margin'] = '0px'
          ..['max-lines'] = '1'
          ..['text-align'] = 'left'
          ..['text-overflow'] = 'ellipsis';
        break;
      case 'description':
        _descriptionOp ??= BuildOp(onWidgets: (meta, widgets) {
          _description = wf.buildColumnPlaceholder(meta, widgets);
          return [_description];
        });
        childMeta.register(_descriptionOp);
        break;
    }
  }

  Iterable<Widget> onWidgets(
      BuildMetadata _, Iterable<WidgetPlaceholder> widgets) {
    widgets = widgets.toList(growable: false);
    final expanded = <Widget>[];
    for (final widget in widgets) {
      if (widget == _description) {
        expanded.add(Expanded(child: widget));
      } else {
        expanded.add(widget);
      }
    }

    le._info = WidgetPlaceholder<_LinkExpanderInfo>(
      this,
      child: LayoutBuilder(
        builder: (_, bc) => Padding(
          padding: const EdgeInsets.symmetric(vertical: kPostBodyPadding),
          child: Column(
            children: bc.maxHeight.isFinite ? expanded : widgets,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.max,
          ),
        ),
      ),
    );

    return [le._info];
  }
}

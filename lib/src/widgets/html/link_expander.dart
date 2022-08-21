part of '../html.dart';

const kLinkExpanderSquareThumbnailSize = 120.0;

class LinkExpander {
  final BuildMetadata linkMeta;
  final TinhteWidgetFactory wf;

  WidgetPlaceholder? _info;
  bool? _isCover;
  WidgetPlaceholder? _thumbnail;

  LinkExpander(this.wf, this.linkMeta);

  BuildOp? _leOp;
  BuildOp get op {
    return _leOp ??= BuildOp(
      defaultStyles: (_) => {'margin': '0.5em 0'},
      onChild: onChild,
      onWidgets: onWidgets,
    );
  }

  void onChild(BuildMetadata childMeta) {
    final e = childMeta.element;
    switch (e.localName) {
      case 'div':
        if (e.classes.contains('thumbnail')) {
          _isCover = e.classes.contains('thumbnail-cover');

          childMeta.register(BuildOp(onWidgets: (meta, widgets) {
            final thumbnail =
                _thumbnail = wf.buildColumnPlaceholder(meta, widgets);
            if (thumbnail == null) return [];
            return [thumbnail];
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
          childMeta.tsb.enqueue((p, dynamic _) =>
              p.copyWith(style: p.style.copyWith(color: Colors.grey)));
        }
        break;
    }
  }

  Iterable<Widget> onWidgets(BuildMetadata _, Iterable<WidgetPlaceholder> __) {
    final scopedInfo = _info;
    final scopedThumbnail = _thumbnail;
    if (scopedInfo == null || scopedThumbnail == null) return [];

    return [
      _isCover != false
          ? _buildCover(scopedThumbnail, scopedInfo)
          : _buildSquare(scopedThumbnail, scopedInfo),
    ];
  }

  Widget _buildBox(BuildMetadata meta, Widget child, {double? width}) {
    final a = meta.element.attributes;
    final fullUrl = wf.urlFull(a['href'] ?? '');
    final onTap = fullUrl != null ? wf.gestureTapCallback(fullUrl) : null;

    return WidgetPlaceholder<LinkExpander>(this)
      ..wrapWith((context, previous) {
        final decoBox =
            wf.buildDecoration(meta, child, color: Theme.of(context).cardColor);
        if (decoBox == null) return previous;
        Widget built = decoBox;

        if (width != null) {
          built = CssSizing(
            child: built,
            maxWidth: CssSizingValue.value(width),
            minWidth: CssSizingValue.value(width),
          );
        }

        if (onTap != null) {
          built = wf.buildGestureDetector(meta, built, onTap) ?? built;
        }

        return built;
      });
  }

  Widget _buildSquare(Widget left, Widget right) => _buildBox(
        linkMeta,
        LayoutBuilder(
          builder: (_, bc) {
            if (bc.maxWidth < 480) return right;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                left,
                Expanded(
                  child: SizedBox(
                    height: kLinkExpanderSquareThumbnailSize,
                    child: right,
                  ),
                ),
              ],
            );
          },
        ),
      );

  Widget _buildCover(Widget top, Widget bottom) => _buildBox(
        linkMeta,
        Column(children: [top, bottom]),
        width: 480,
      );

  static BuildOp? _oembedOp;
  static BuildOp getOembedOp() {
    return _oembedOp ??= BuildOp(
      defaultStyles: (_) => {'margin': '0.5em 0'},
      onWidgets: (meta, _) => [_buildOembedWebView(meta.element.outerHtml)],
    );
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

  Widget? _description;
  BuildOp? _descriptionOp;

  _LinkExpanderInfo(this.wf, this.le, this.infoMeta);

  BuildOp? _infoOp;
  BuildOp get op {
    return _infoOp ??= BuildOp(
      onChild: onChild,
      onWidgets: onWidgets,
    );
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
        final descriptionOp =
            _descriptionOp ??= BuildOp(onWidgets: (meta, widgets) {
          final description =
              _description = wf.buildColumnPlaceholder(meta, widgets);
          if (description == null) return [];
          return [description];
        });
        childMeta.register(descriptionOp);
        break;
    }
  }

  Iterable<Widget> onWidgets(
      BuildMetadata _, Iterable<WidgetPlaceholder> widgets) {
    final scopedDescription = _description;
    final widget = le._info = WidgetPlaceholder<_LinkExpanderInfo>(
      this,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: kPostBodyPadding),
        child: LayoutBuilder(
          builder: (_, bc) {
            Iterable<Widget> children = widgets;
            if (bc.maxHeight.isFinite) {
              children = children.map(
                (child) => identical(child, scopedDescription)
                    ? Expanded(child: child)
                    : child,
              );
            }

            return Column(
              children: children.toList(growable: false),
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.max,
            );
          },
        ),
      ),
    );

    return [widget];
  }
}

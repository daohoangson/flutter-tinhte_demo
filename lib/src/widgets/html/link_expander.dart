part of '../html.dart';

const kLinkExpanderSquareThumbnailSize = 120.0;

class LinkExpander {
  final TinhteWidgetFactory wf;

  LinkExpander(this.wf);

  BuildOp _buildOp;
  BuildOp _infoOp;
  BuildOp _thumbnailOp;

  BuildOp get buildOp {
    _buildOp ??= BuildOp(
      onChild: (meta, e) {
        final c = e.classes;
        switch (e.localName) {
          case 'div':
            if (c.contains('thumbnail')) {
              lazySet(meta, buildOp: thumbnailOp);
            } else if (c.contains('info')) {
              lazySet(meta, buildOp: infoOp);
            }
            break;
          case 'h4':
            lazySet(meta, styles: ['margin', '0px']);
            break;
          case 'span':
            if (c.contains('host')) {
              lazySet(meta, color: Colors.grey);
            }
            break;
        }

        return meta;
      },
      onWidgets: (meta, widgets) => build(meta, widgets),
    );
    return _buildOp;
  }

  BuildOp get infoOp {
    _infoOp ??= BuildOp(
      onWidgets: (meta, widgets) => [_Info(wf.buildColumn(widgets))],
    );
    return _infoOp;
  }

  BuildOp get thumbnailOp {
    _thumbnailOp ??= BuildOp(
      onWidgets: (meta, widgets) => [
        _Thumbnail(
          widgets.first,
          isCover: meta.domElement.classes.contains('thumbnail-cover'),
        ),
      ],
    );
    return _thumbnailOp;
  }

  Iterable<Widget> build(NodeMetadata meta, Iterable<Widget> children) {
    _Thumbnail thumbnail;
    _Info info;

    for (final child in children) {
      if (child is _Thumbnail) thumbnail = child;
      if (child is _Info) info = child;
    }

    if (info == null) return null;

    return [
      Padding(
        child: Wrap(
          children: <Widget>[
            thumbnail?.isCover != false
                ? _buildCover(meta, thumbnail, info)
                : _buildSquare(meta, thumbnail, info),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 10),
      ),
    ];
  }

  Widget _buildBox(NodeMetadata meta, Widget child) {
    final a = meta.domElement.attributes;
    final href = a.containsKey('href') ? a['href'] : null;
    final fullUrl = wf.constructFullUrl(href) ?? href;
    final onTap = wf.buildGestureTapCallbackForUrl(fullUrl);

    return wf.buildGestureDetector(
      Builder(
        builder: (context) => DecoratedBox(
          decoration: BoxDecoration(color: Theme.of(context).cardColor),
          child: child,
        ),
      ),
      onTap,
    );
  }

  Widget _buildSquare(NodeMetadata meta, _Thumbnail thumbnail, _Info info) =>
      _buildBox(
        meta,
        LayoutBuilder(
          builder: (_, bc) {
            if (bc.maxWidth < 480) return info;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                thumbnail,
                Expanded(
                  child: SizedBox(
                    height: kLinkExpanderSquareThumbnailSize,
                    child: info,
                  ),
                ),
              ],
            );
          },
        ),
      );

  Widget _buildCover(NodeMetadata meta, _Thumbnail thumbnail, _Info info) =>
      SizedBox(
        child: _buildBox(
          meta,
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              thumbnail ?? Container(),
              info,
            ],
          ),
        ),
        width: 480,
      );
}

class _Thumbnail extends StatelessWidget {
  final Widget child;
  final bool isCover;

  _Thumbnail(this.child, {this.isCover = false});

  @override
  Widget build(BuildContext context) => isCover
      ? child
      : SizedBox(
          width: kLinkExpanderSquareThumbnailSize,
          height: kLinkExpanderSquareThumbnailSize,
          child: child,
        );
}

class _Info extends StatelessWidget {
  final Widget child;

  _Info(this.child);

  @override
  Widget build(BuildContext context) => Padding(
        child: child,
        padding: const EdgeInsets.all(5),
      );
}

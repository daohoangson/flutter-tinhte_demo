part of '../html.dart';

const kColumns = 3;
const kSpacing = 3.0;

class Galleria {
  final TinhteWidgetFactory wf;

  BuildOp _buildOp;
  BuildOp _childOpA;
  BuildOp _childOpLi;

  Galleria(this.wf);

  BuildOp get buildOp {
    _buildOp ??= BuildOp(
      onChild: (meta, e) {
        switch (e.localName) {
          case 'a':
            meta.op = childOpA;
            break;
          case 'img':
            meta.isBlockElement = true;
            break;
          case 'li':
            meta.op = childOpLi;
            break;
        }

        return meta;
      },
      onWidgets: (meta, widgets) {
        final children = <Widget>[];
        final lb = LbTrigger();

        var i = -1;
        for (final widget in widgets) {
          if (!(widget is _GalleriaItem)) continue;
          i++;

          final item = widget as _GalleriaItem;
          lb.sources.add(item.source);
          if (item.caption != null) {
            lb.captions[i] = item.caption;
          }

          children.add(lb.buildGestureDetector(i, item.image));
        }

        if (children.isEmpty) return [Container()];

        return [_GalleriaGrid(children)];
      },
    );

    return _buildOp;
  }

  BuildOp get childOpA {
    _childOpA ??= BuildOp(
      onPieces: (meta, pieces) {
        final a = meta.domElement.attributes;
        if (!a.containsKey('href')) return pieces;

        return pieces.map(
          (piece) {
            if (!piece.hasWidgets || piece.widgets.length != 1) return piece;
            final first = piece.widgets.first;
            if (first is! Image) return piece;

            return BuiltPiece.widgets([_GalleriaPlaceholder(a['href'], first)]);
          },
        );
      },
      priority: 0,
    );

    return _childOpA;
  }

  BuildOp get childOpLi {
    _childOpLi ??= BuildOp(onWidgets: (meta, widgets) {
      Widget caption, image;
      String source;
      for (final widget in widgets) {
        if (widget is WidgetPlaceholder<TextBits>) {
          caption = widget;
        } else if (widget is _GalleriaPlaceholder) {
          image = Image(image: widget.image, fit: BoxFit.cover);
          source = widget.source;
        }
      }

      if (source?.isNotEmpty != true || image == null) return null;

      return [_GalleriaItem(caption, image, source)];
    });

    return _childOpLi;
  }
}

class _GalleriaGrid extends StatelessWidget {
  final List<Widget> children;

  _GalleriaGrid(this.children);

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (_, bc) {
          final columns = bc.maxWidth / 150;

          return GridView.count(
            crossAxisCount: columns.ceil(),
            crossAxisSpacing: 5,
            childAspectRatio: 4 / 3,
            children: children,
            shrinkWrap: true,
            mainAxisSpacing: 5,
            padding: const EdgeInsets.all(0),
            primary: false,
          );
        },
      );
}

class _GalleriaItem extends StatelessWidget {
  final Widget caption;
  final Widget image;
  final String source;

  _GalleriaItem(this.caption, this.image, this.source)
      : assert(image != null),
        assert(source != null);

  @override
  Widget build(BuildContext context) => image;
}

class _GalleriaPlaceholder extends WidgetPlaceholder<Galleria> {
  final String source;
  final ImageProvider image;

  _GalleriaPlaceholder(this.source, Image image)
      : image = image.image,
        super(builder: _builder, children: [image]);

  static Iterable<Widget> _builder(
          BuildContext _, Iterable<Widget> children, Galleria __) =>
      children;
}

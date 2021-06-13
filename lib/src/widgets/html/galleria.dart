part of '../html.dart';

const kColumns = 3;
const kSpacing = 3.0;

class Galleria {
  final BuildMetadata galleryMeta;
  final TinhteWidgetFactory wf;

  final _lb = LbTrigger();

  Galleria(this.wf, this.galleryMeta);

  BuildOp _galleriaOp;
  BuildOp get op {
    _galleriaOp ??= BuildOp(
      onChild: onChild,
      onWidgets: onWidgets,
    );
    return _galleriaOp;
  }

  void onChild(BuildMetadata childMeta) {
    final e = childMeta.element;
    if (e.parent != galleryMeta.element) return;
    if (e.localName != 'li') return;

    childMeta.register(_GalleriaItem(wf, this, childMeta).op);
  }

  Iterable<Widget> onWidgets(
          BuildMetadata _, Iterable<WidgetPlaceholder> widgets) =>
      [
        WidgetPlaceholder<Galleria>(this,
            child: _GalleriaGrid(widgets.toList(growable: false)))
      ];
}

class _GalleriaItem {
  final BuildMetadata itemMeta;
  final Galleria galleria;
  final WidgetFactory wf;

  Widget _description;
  BuildOp _descriptionOp;
  String _source;
  WidgetPlaceholder _trigger;
  BuildOp _triggerOp;

  _GalleriaItem(this.wf, this.galleria, this.itemMeta);

  BuildOp _itemOp;
  BuildOp get op {
    _itemOp ??= BuildOp(
      onChild: onChild,
      onWidgets: onWidgets,
    );
    return _itemOp;
  }

  void onChild(BuildMetadata childMeta) {
    final e = childMeta.element;
    if (e.parent != itemMeta.element) return;

    switch (e.className) {
      case 'LbTrigger':
        _source ??= wf.urlFull(e.attributes['href']);
        _triggerOp ??= BuildOp(
          // onChild: (childMeta) {
          //   if (childMeta.domElement.localName == 'img') {
          //     childMeta.isBlockElement = true;
          //   }
          // },
          onWidgets: (meta, widgets) {
            // bypass built-in A tag handling with 0 priority
            // and NOT returning anything in `onWidgets`
            _trigger = wf.buildColumnPlaceholder(meta, widgets);
            return [];
          },
          priority: 0,
        );
        childMeta.register(_triggerOp);
        break;
      case 'Tinhte_Gallery_Description':
        _descriptionOp ??= BuildOp(onWidgets: (meta, widgets) {
          meta.tsb.enqueue((p, _) => p.copyWith(
              style: p
                  .getDependency<ThemeData>()
                  .textTheme
                  .caption
                  .copyWith(color: kCaptionColor)));
          _description = wf.buildColumnPlaceholder(meta, widgets);
          return [];
        });
        childMeta.register(_descriptionOp);
        break;
    }
  }

  Iterable<Widget> onWidgets(
      BuildMetadata _, Iterable<WidgetPlaceholder> widgets) {
    if (_source == null) return widgets;
    if (_trigger == null) return widgets;

    final index = galleria._lb.addSource(
      LbTriggerSource.image(_source),
      caption: _description,
    );
    _trigger.wrapWith((context, child) =>
        galleria._lb.buildGestureDetector(context, child, index));

    return [_trigger];
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

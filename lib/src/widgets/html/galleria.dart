part of '../html.dart';

const kColumns = 3;
const kSpacing = 3.0;

class Galleria {
  final BuildMetadata galleryMeta;
  final TinhteWidgetFactory wf;

  final _lb = LbTrigger();

  Galleria(this.wf, this.galleryMeta);

  BuildOp? _galleriaOp;
  BuildOp get op {
    return _galleriaOp ??= BuildOp(
      onChild: onChild,
      onWidgets: onWidgets,
    );
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

  Widget? _description;
  BuildOp? _descriptionOp;
  String? _source;
  WidgetPlaceholder? _trigger;
  BuildOp? _triggerOp;

  _GalleriaItem(this.wf, this.galleria, this.itemMeta);

  BuildOp? _itemOp;
  BuildOp get op {
    return _itemOp ??= BuildOp(
      onChild: onChild,
      onWidgets: onWidgets,
    );
  }

  void onChild(BuildMetadata childMeta) {
    final e = childMeta.element;
    if (e.parent != itemMeta.element) return;

    switch (e.className) {
      case 'LbTrigger':
        _source ??= wf.urlFull(e.attributes['href'] ?? '');
        final triggerOp = _triggerOp ??= BuildOp(
          onWidgets: (meta, widgets) {
            // bypass built-in A tag handling with 0 priority
            // and NOT returning anything in `onWidgets`
            _trigger = wf.buildColumnPlaceholder(meta, widgets);
            return [];
          },
          priority: 0,
        );
        childMeta.register(triggerOp);
        break;
      case 'Tinhte_Gallery_Description':
        final descriptionOp = _descriptionOp ??= BuildOp(
          onWidgets: (meta, widgets) {
            meta.tsb.enqueue((p, dynamic _) => p.copyWith(
                style: p
                    .getDependency<ThemeData>()
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: kCaptionColor)));
            _description = wf.buildColumnPlaceholder(meta, widgets);
            return [];
          },
        );
        childMeta.register(descriptionOp);
        break;
    }
  }

  Iterable<Widget> onWidgets(
      BuildMetadata _, Iterable<WidgetPlaceholder> widgets) {
    final scopedSource = _source;
    final scopedTrigger = _trigger;
    if (scopedSource == null || scopedTrigger == null) return widgets;

    final index = galleria._lb.addSource(
      LbTriggerSource.image(scopedSource),
      caption: _description,
    );
    scopedTrigger.wrapWith((context, child) =>
        galleria._lb.buildGestureDetector(context, child, index));

    return [scopedTrigger];
  }
}

class _GalleriaGrid extends StatelessWidget {
  final List<Widget> children;

  const _GalleriaGrid(this.children);

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (_, bc) {
          final columns = bc.maxWidth / 150;

          return GridView.count(
            crossAxisCount: columns.ceil(),
            crossAxisSpacing: 5,
            childAspectRatio: 4 / 3,
            shrinkWrap: true,
            mainAxisSpacing: 5,
            padding: const EdgeInsets.all(0),
            primary: false,
            children: children,
          );
        },
      );
}

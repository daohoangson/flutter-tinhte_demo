part of '../html.dart';

const kColumns = 3;
const kSpacing = 3.0;

class Galleria {
  final BuildTree galleryTree;
  final TinhteWidgetFactory wf;

  final _items = <WidgetPlaceholder>[];
  final _lb = LbTrigger();

  Galleria(this.wf, this.galleryTree);

  BuildOp? _galleriaOp;
  BuildOp get op {
    return _galleriaOp ??= BuildOp.v1(
      onChild: onChild,
      onRenderBlock: onRenderBlock,
    );
  }

  void onChild(BuildTree _, BuildTree subTree) {
    final e = subTree.element;
    if (e.parent != galleryTree.element) return;
    if (e.localName != 'li') return;
    subTree.register(_GalleriaItem(wf, this, subTree).op);
  }

  Widget onRenderBlock(BuildTree _, WidgetPlaceholder placeholder) =>
      _items.isNotEmpty ? _GalleriaGrid(_items) : placeholder;
}

class _GalleriaItem {
  final BuildTree itemTree;
  final Galleria galleria;
  final WidgetFactory wf;

  Widget? _description;
  BuildOp? _descriptionOp;
  String? _source;
  Widget? _trigger;
  BuildOp? _triggerOp;

  _GalleriaItem(this.wf, this.galleria, this.itemTree);

  BuildOp? _itemOp;
  BuildOp get op {
    return _itemOp ??= BuildOp.v1(
      onChild: onChild,
      onRenderBlock: onRenderBlock,
    );
  }

  void onChild(BuildTree _, BuildTree subSubTree) {
    final e = subSubTree.element;
    if (e.parent != itemTree.element) return;

    switch (e.className) {
      case 'LbTrigger':
        _source ??= wf.urlFull(e.attributes['href'] ?? '');
        final triggerOp = _triggerOp ??= BuildOp.v1(
          alwaysRenderBlock: true,
          onRenderedBlock: (_, block) => _trigger = block,
        );
        subSubTree.register(triggerOp);
        break;
      case 'Tinhte_Gallery_Description':
        final descriptionOp = _descriptionOp ??= BuildOp.v1(
          alwaysRenderBlock: true,
          onParsed: (descriptionTree) {
            return descriptionTree
              ..apply<BuildContext?>(
                (style, context) => style.copyWith(
                  textStyle: Theme.of(context!)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: kCaptionColor),
                ),
                null,
              );
          },
          onRenderedBlock: (_, block) => _description = block,
        );
        subSubTree.register(descriptionOp);
        break;
    }
  }

  Widget onRenderBlock(BuildTree _, WidgetPlaceholder placeholder) {
    final scopedSource = _source;
    final scopedTrigger = _trigger;
    if (scopedSource == null || scopedTrigger == null) return placeholder;

    final index = galleria._lb.addSource(
      LbTriggerSource.image(scopedSource),
      caption: _description,
    );

    galleria._items.add(
      WidgetPlaceholder.lazy(
        scopedTrigger,
        debugLabel: '${itemTree.element.localName}--galleriaItem',
      ).wrapWith(
        (context, child) =>
            galleria._lb.buildGestureDetector(context, child, index),
      ),
    );

    return widget0;
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

part of '../html.dart';

const kColumns = 3;
const kSpacing = 3.0;

class Galleria {
  final TinhteWidgetFactory wf;
  final key = UniqueKey();

  BuildOp _buildOp;
  BuildOp _imgOp;

  Galleria(this.wf);

  BuildOp get buildOp {
    _buildOp ??= BuildOp(
      onMetadata: (meta) => lazySet(meta, key: key),
      onWidgets: (meta, iterable) {
        final widgets = iterable.toList();
        final rows = (widgets.length / kColumns).ceil();
        final List<Widget> newWidgets = List();

        for (int r = 0; r < rows; r++) {
          final List<Widget> rowWidgets = List();
          for (int c = 0; c < kColumns; c++) {
            final i = r * kColumns + c;
            if (i < widgets.length) {
              rowWidgets.add(Expanded(child: widgets[i]));
            }

            if (c < kColumns - 1) {
              rowWidgets.add(SizedBox(width: kSpacing));
            }
          }

          newWidgets.add(Row(children: rowWidgets));
          newWidgets.add(SizedBox(height: kSpacing));
        }

        return wf.buildColumn(newWidgets);
      },
    );

    return _buildOp;
  }

  BuildOp get imgOp {
    _imgOp ??= BuildOp(onWidgets: (meta, _) {
      final a = meta.domElement.attributes;
      final src = a.containsKey('src') ? a['src'] : null;
      final imageUrl = wf.constructFullUrl(src);
      if (imageUrl?.isEmpty != false) return null;

      return AspectRatio(
        aspectRatio: 16 / 9,
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
        ),
      );
    });

    return _imgOp;
  }
}

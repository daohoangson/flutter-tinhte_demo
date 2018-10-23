part of '../html.dart';

BuildOp galleria(TinhteWidgetFactory wf) => BuildOp(
      onWidgets: (widgets) {
        wf._isInGalleria = false;

        final columns = 3;
        final rows = (widgets.length / columns).ceil();
        final spacing = 3.0;
        final List<Widget> newWidgets = List();

        for (int r = 0; r < rows; r++) {
          final List<Widget> rowWidgets = List();
          for (int c = 0; c < columns; c++) {
            final i = r * columns + c;
            if (i < widgets.length) {
              rowWidgets.add(Expanded(
                child: widgets[i],
              ));
            }

            if (c < columns - 1) {
              rowWidgets.add(SizedBox(width: spacing));
            }
          }
          newWidgets.add(Row(children: rowWidgets));
          newWidgets.add(SizedBox(height: spacing));
        }

        return newWidgets;
      },
    );

import 'package:flutter/widgets.dart';

import 'package:tinhte_html_widget/config.dart';
import 'package:tinhte_html_widget/html_widget.dart' as packaged;
import 'package:tinhte_html_widget/widget_factory.dart';

final wf = WidgetFactory(
    config: Config(
  baseUrl: Uri.parse('https://tinhte.vn'),
  parseElementCallback: (e) {
    if (e.className == 'bbCodeBlock bbCodeQuote') {
      return false;
    }

    return true;
  },
));

class HtmlWidget extends StatelessWidget {
  final String html;
  HtmlWidget({Key key, @required this.html}) : super(key: key);

  @override
  Widget build(BuildContext context) => DefaultTextStyle(
        child: packaged.HtmlWidget(
          html: html,
          widgetFactory: wf,
        ),
        style: DefaultTextStyle.of(context).style.copyWith(
          fontSize: 16.0,
        ),
      );
}

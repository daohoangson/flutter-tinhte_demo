import 'package:flutter/material.dart';

import 'package:tinhte_html_widget/config.dart';
import 'package:tinhte_html_widget/html_widget.dart' as packaged;
import 'package:tinhte_html_widget/widget_factory.dart';

class HtmlWidget extends StatelessWidget {
  final String html;
  final bool isFirstPost;

  HtmlWidget({Key key, @required this.html, this.isFirstPost = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) => DefaultTextStyle(
        child: packaged.HtmlWidget(
          html: html,
          widgetFactory: WidgetFactory(
            config: Config(
              baseUrl: Uri.parse('https://tinhte.vn'),
              colorHyperlink: Theme.of(context).accentColor,
              parseElementCallback: (e) {
                if (e.className == 'bbCodeBlock bbCodeQuote') {
                  return false;
                }

                return true;
              },
            ),
          ),
        ),
        style: DefaultTextStyle.of(context).style.copyWith(
              fontSize: isFirstPost ? 16.0 : 15.0,
            ),
      );
}

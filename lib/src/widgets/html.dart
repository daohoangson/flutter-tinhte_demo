import 'package:flutter/material.dart';
import 'package:tinhte_html_widget/config.dart';
import 'package:tinhte_html_widget/html_widget.dart' as packaged;
import 'package:tinhte_html_widget/widget_factory.dart';

import 'image.dart';

class HtmlWidget extends StatelessWidget {
  final String html;
  final bool isFirstPost;

  HtmlWidget({Key key, @required this.html, this.isFirstPost = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) => DefaultTextStyle(
        child: packaged.HtmlWidget(
          html: html,
          widgetFactory: _WidgetFactory(context),
        ),
        style: DefaultTextStyle.of(context).style.copyWith(
              fontSize: isFirstPost ? 16.0 : 15.0,
            ),
      );
}

class _WidgetFactory extends WidgetFactory {
  final BuildContext context;

  _WidgetFactory(this.context)
      : super(
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
        );

  @override
  Widget buildImageWidget(NodeImage image) {
    if (image.src?.isNotEmpty == true &&
        image.height != null &&
        image.width != null) {
      final proxyUrl = getProxyUrl(
        image.src,
        MediaQuery.of(context).size.width,
        imageWidth: image.width,
      );
      if (proxyUrl != image.src) {
        return super.buildImageWidget(NodeImage(
          height: image.height,
          src: proxyUrl,
          width: image.width,
        ));
      }
    }

    return super.buildImageWidget(image);
  }
}

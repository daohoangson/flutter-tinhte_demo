import 'package:flutter/material.dart';
import 'package:tinhte_html_widget/config.dart';
import 'package:tinhte_html_widget/html_widget.dart' as packaged;
import 'package:tinhte_html_widget/widget_factory.dart';

import 'image.dart';

final _smilies = {
  'Smile': '🙂',
  'Wink': '😉',
  'Frown': '😔',
  'Mad': '😡',
  'Confused': '😕',
  'Cool': '😎',
  'Stick Out Tongue': '😝',
  'Big Grin': '😁',
  'Eek!': '🤪',
  'Oops!': '🙈',
  'Roll Eyes': '🙄',
  'Er... what?': '😳',
};

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
            parseElementCallback: (e, meta) {
              switch (e.className) {
                case 'bbCodeBlock bbCodeQuote':
                  meta = lazySet(meta, isNotRenderable: true);
                  break;
                case 'smilie':
                  final title = e.attributes['data-title'];
                  if (_smilies.containsKey(title)) {
                    meta = lazyAddNode(meta, text: _smilies[title]);
                  }
                  break;
              }

              return meta;
            },
          ),
        );

  @override
  Widget buildImageWidget(NodeImage image) {
    final mqd = MediaQuery.of(context);
    final proxyUrl = getResizedUrl(
      boxWidth: mqd.devicePixelRatio * mqd.size.width,
      imageHeight: image.height,
      imageUrl: image.src,
      imageWidth: image.width,
    );
    if (proxyUrl != null) {
      image = NodeImage(
        height: image.height,
        src: proxyUrl,
        width: image.width,
      );
    }

    return super.buildImageWidget(image);
  }
}

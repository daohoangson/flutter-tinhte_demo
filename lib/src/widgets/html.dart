import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart'
    show lazySet, BuildOp, NodeMetadata;
import 'package:html/dom.dart' as dom;

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

class TinhteHtmlWidget extends StatelessWidget {
  final String html;
  final bool isFirstPost;

  TinhteHtmlWidget(
    this.html, {
    this.isFirstPost = false,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dts = DefaultTextStyle.of(context).style;
    final config = Config(
      baseUrl: Uri.parse('https://tinhte.vn'),
    );

    return DefaultTextStyle(
      child: HtmlWidget(
        html,
        config: config,
        wfBuilder: (context) => TinhteWidgetFactory(context, config),
      ),
      style: dts.copyWith(
        fontSize: dts.fontSize + (isFirstPost ? 0 : -1),
      ),
    );
  }
}

class TinhteWidgetFactory extends WidgetFactory {
  TinhteWidgetFactory(BuildContext context, Config config)
      : super(context, config);

  @override
  NodeMetadata collectMetadata(dom.Element e) {
    switch (e.className) {
      case 'bbCodeBlock bbCodeQuote':
        return lazySet(null, isNotRenderable: true);
      case 'smilie':
        final title = e.attributes['data-title'];
        if (_smilies.containsKey(title)) {
          final text = _smilies[title];
          return lazySet(null,
              buildOp: BuildOp(onProcess: (_, __, write) => write(text)));
        }
        break;
    }

    return super.collectMetadata(e);
  }
}

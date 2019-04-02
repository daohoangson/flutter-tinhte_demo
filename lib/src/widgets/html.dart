import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart'
    show lazySet, BuildOp, NodeMetadata;
import 'package:html/dom.dart' as dom;

import 'html/lb_trigger.dart';

part 'html/galleria.dart';

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

TextStyle getPostBodyTextStyle(BuildContext context, bool isFirstPost) {
  final textStyle = Theme.of(context).textTheme.body1;
  return textStyle.copyWith(
    fontSize: textStyle.fontSize + (isFirstPost ? -1 : -2),
  );
}

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
    final config = Config(
      baseUrl: Uri.parse('https://tinhte.vn'),
      webView: true,
    );

    return DefaultTextStyle(
      child: HtmlWidget(
        html,
        config: config,
        wfBuilder: (c) => TinhteWidgetFactory(c, config),
      ),
      style: getPostBodyTextStyle(context, isFirstPost),
    );
  }
}

class TinhteWidgetFactory extends WidgetFactory {
  bool _isInGalleria = false;
  LbTrigger _lbTrigger;

  TinhteWidgetFactory(BuildContext context, Config config)
      : super(context, config);

  @override
  Widget buildImageWidget(String src, {int height, int width}) {
    if (_isInGalleria) {
      final imageUrl = buildFullUrl(src, config.baseUrl);
      if (imageUrl?.isEmpty != false) return null;

      return AspectRatio(
        aspectRatio: 16 / 9,
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
        ),
      );
    }

    return super.buildImageWidget(src, height: height, width: width);
  }

  @override
  Widget buildImageWidgetFromUrl(String url) {
    final imageUrl = buildFullUrl(url, config.baseUrl);
    if (imageUrl?.isEmpty != false) return null;

    return Image(
      image: CachedNetworkImageProvider(imageUrl),
      fit: BoxFit.cover,
    );
  }

  @override
  NodeMetadata parseElement(dom.Element e) {
    switch (e.className) {
      case 'LbTrigger':
        if (e.localName == 'a' && e.attributes.containsKey('href')) {
          final href = e.attributes['href'];
          _lbTrigger ??= LbTrigger(this.context);

          return lazySet(
            null,
            buildOp: BuildOp(
              onWidgets: _lbTrigger.prepareBuildOpOnWidgets(href),
            ),
          );
        }
        break;
      case 'Tinhte_Galleria':
        _isInGalleria = true;
        return lazySet(null, buildOp: galleria(this));
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

    return super.parseElement(e);
  }
}

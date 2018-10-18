import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart'
    as core;
import 'package:html/dom.dart' as dom;

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
  Widget buildGestureDetectorToLaunchUrl(Widget child, String url) {
    if (child == null || url?.isNotEmpty != true) return null;

    return GestureDetector(
      onTap: prepareGestureTapCallbackToLaunchUrl(
        buildFullUrl(url, config.baseUrl),
      ),
      child: Stack(
        children: <Widget>[
          child,
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, bc) => Icon(
                    Icons.open_in_new,
                    color: Theme.of(context).accentColor.withAlpha(178),
                    size: min(bc.maxHeight, bc.maxWidth) / 2.5,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget buildImageWidget(core.NodeImage image) {
    final mqd = MediaQuery.of(context);
    final proxyUrl = getResizedUrl(
      boxWidth: mqd.devicePixelRatio * mqd.size.width,
      imageHeight: image.height,
      imageUrl: image.src,
      imageWidth: image.width,
    );
    if (proxyUrl != null) {
      image = core.NodeImage(
        height: image.height,
        src: proxyUrl,
        width: image.width,
      );
    }

    return super.buildImageWidget(image);
  }

  @override
  core.NodeMetadata collectMetadata(dom.Element e) {
    var meta = super.collectMetadata(e);

    switch (e.className) {
      case 'bbCodeBlock bbCodeQuote':
        meta = core.lazySet(meta, isNotRenderable: true);
        break;
      case 'smilie':
        final title = e.attributes['data-title'];
        if (_smilies.containsKey(title)) {
          meta = core.lazyAddNode(meta, text: _smilies[title]);
        }
        break;
    }

    return meta;
  }
}

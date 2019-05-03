import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:html/dom.dart' as dom;

import 'html/lb_trigger.dart';
import 'image.dart';

part 'html/galleria.dart';
part 'html/link_expander.dart';

const _kSmilies = {
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
    fontSize: textStyle.fontSize + (isFirstPost ? 0 : -1),
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
  Widget build(BuildContext context) => HtmlWidget(
        html,
        baseUrl: Uri.parse('https://tinhte.vn'),
        hyperlinkColor: Theme.of(context).accentColor,
        textStyle: getPostBodyTextStyle(context, isFirstPost),
        webView: true,
        wf: TinhteWidgetFactory(),
      );
}

class TinhteWidgetFactory extends WidgetFactory {
  BuildOp _attachImageOp;
  BuildOp _chrOp;
  BuildOp _smilieOp;

  Galleria _galleria;
  LbTrigger _lbTrigger;
  LinkExpander _linkExpander;

  BuildOp get attachImageOp {
    _attachImageOp ??= BuildOp(onWidgets: (meta, __) {
      final e = meta.domElement;
      final a = e.attributes;
      final imageUrl = constructFullUrl(a['src']);
      if (imageUrl?.isEmpty != false) return null;

      return AttachmentImageWidget(
        height: int.tryParse(e.attributes['data-height']),
        permalink: e.attributes['data-permalink'],
        src: imageUrl,
        width: int.tryParse(e.attributes['data-width']),
      );
    });
    return _attachImageOp;
  }

  BuildOp get chrOp {
    _chrOp ??= BuildOp(onWidgets: (meta, __) {
      final a = meta.domElement.attributes;
      final url = constructFullUrl(a['href']);
      if (url?.isEmpty != false) return null;

      return WebView(url, aspectRatio: 16 / 9, getDimensions: true);
    });
    return _chrOp;
  }

  BuildOp get smilieOp {
    _smilieOp ??= BuildOp(
      onPieces: (meta, pieces) {
        final a = meta.domElement.attributes;
        if (!a.containsKey('data-title')) return pieces;
        final title = a['data-title'];
        if (!_kSmilies.containsKey(title)) return pieces;

        return pieces
          ..first.block.rebuildBits((b) => b.rebuild(data: _kSmilies[title]));
      },
    );
    return _smilieOp;
  }

  Galleria get galleria {
    _galleria ??= Galleria(this);
    return _galleria;
  }

  LbTrigger get lbTrigger {
    _lbTrigger ??= LbTrigger();
    return _lbTrigger;
  }

  LinkExpander get linkExpander {
    _linkExpander ??= LinkExpander(this);
    return _linkExpander;
  }

  @override
  NodeMetadata parseElement(NodeMetadata meta, dom.Element e) {
    switch (e.localName) {
      case 'a':
        if (e.attributes.containsKey('data-chr') &&
            e.attributes['data-chr'] == 'true' &&
            e.attributes.containsKey('href')) {
          return lazySet(null, buildOp: chrOp);
        }

        if (e.classes.contains('LinkExpander') &&
            e.classes.contains('expanded')) {
          return lazySet(null, buildOp: linkExpander.buildOp);
        }
        break;
      case 'img':
        if (e.attributes.containsKey('data-height') &&
            e.attributes.containsKey('data-permalink') &&
            e.attributes.containsKey('src') &&
            e.attributes.containsKey('data-width')) {
          return lazySet(null, buildOp: attachImageOp);
        }
        break;
    }

    switch (e.className) {
      case 'LbTrigger':
        return lazySet(null, buildOp: lbTrigger.buildOp);
      case 'Tinhte_Galleria':
        return lazySet(null, buildOp: galleria.buildOp);
      case 'bbCodeBlock bbCodeQuote':
        return lazySet(null, isNotRenderable: true);
      case 'smilie':
        return lazySet(null, buildOp: smilieOp);
    }

    return meta;
  }
}

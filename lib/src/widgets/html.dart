import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:html/dom.dart' as dom;
import 'package:photo_view/photo_view_gallery.dart';

import '../config.dart';
import '../constants.dart';
import '../link.dart';
import 'image.dart';

part 'html/galleria.dart';
part 'html/link_expander.dart';
part 'html/lb_trigger.dart';
part 'html/photo_compare.dart';

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

const _kTextPadding = const EdgeInsets.symmetric(horizontal: kPostBodyPadding);

class TinhteHtmlWidget extends StatelessWidget {
  final String html;
  final Color hyperlinkColor;
  final TextStyle textStyle;

  TinhteHtmlWidget(
    this.html, {
    this.hyperlinkColor,
    Key key,
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => HtmlWidget(
        "<html><body>$html</body></html>",
        baseUrl: Uri.parse(configSiteRoot),
        bodyPadding: const EdgeInsets.only(top: kPostBodyPadding),
        factoryBuilder: (c, hw) => TinhteWidgetFactory(c, hw),
        hyperlinkColor: hyperlinkColor,
        onTapUrl: (url) => launchLink(context, url),
        textStyle: textStyle,
        unsupportedWebViewWorkaroundForIssue37: true,
        webView: true,
      );
}

class TinhteWidgetFactory extends WidgetFactory {
  var _isBuildingBody = 0;

  BuildOp _chrOp;
  BuildOp _smilieOp;
  BuildOp _webViewDataUriOp;

  Galleria _galleria;
  LbTrigger _lbTrigger;
  LinkExpander _linkExpander;
  PhotoCompare _photoCompare;

  TinhteWidgetFactory(BuildContext context, HtmlWidget htmlWidget)
      : super(context, htmlWidget);

  BuildOp get chrOp {
    _chrOp ??= BuildOp(onWidgets: (meta, __) {
      final a = meta.domElement.attributes;
      final url = constructFullUrl(a['href']);
      if (url?.isEmpty != false) return null;

      return [WebView(url, aspectRatio: 16 / 9, getDimensions: true)];
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

  BuildOp get webViewDataUriOp {
    _webViewDataUriOp ??= BuildOp(
      onWidgets: (meta, _) {
        final url = Uri.dataFromString(
          "<html><body>${meta.domElement.outerHtml}</body></html",
          encoding: Encoding.getByName('utf-8'),
          mimeType: 'text/html',
        ).toString();
        debugPrint(url);
        return [WebView(url, aspectRatio: 10, getDimensions: true)];
      },
    );
    return _webViewDataUriOp;
  }

  Galleria get galleria {
    _galleria ??= Galleria(this);
    return _galleria;
  }

  LbTrigger get lbTrigger {
    _lbTrigger ??= LbTrigger(wf: this);
    return _lbTrigger;
  }

  LinkExpander get linkExpander {
    _linkExpander ??= LinkExpander(this);
    return _linkExpander;
  }

  PhotoCompare get photoCompare {
    _photoCompare ??= PhotoCompare(this);
    return _photoCompare;
  }

  @override
  Widget buildBody(Iterable<Widget> children) {
    _isBuildingBody++;
    final built = super.buildBody(children);
    _isBuildingBody--;

    return built;
  }

  @override
  List<Widget> fixOverlappingPaddings(List<Widget> widgets) {
    var fixed = super.fixOverlappingPaddings(widgets);
    if (_isBuildingBody == 0 || fixed?.isNotEmpty != true) return fixed;

    fixed = fixed.map(_buildTextPadding).toList();

    if (_checkIsText(fixed.last)) {
      fixed.add(buildPadding(widget0, const EdgeInsets.only(bottom: 10)));
    }

    return fixed;
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

        if (e.classes.contains('LbTrigger') &&
            e.attributes.containsKey('data-height') &&
            e.attributes.containsKey('data-permalink') &&
            e.attributes.containsKey('data-width')) {
          return lazySet(null, buildOp: lbTrigger.buildOp);
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
          return lazySet(meta, buildOp: lbTrigger.buildOp);
        }
        break;
      case 'script':
        if (e.attributes.containsKey('src') &&
            e.attributes['src'] == 'https://e.infogr.am/js/embed.js') {
          return lazySet(null, buildOp: webViewDataUriOp);
        }
        break;
    }

    switch (e.className) {
      case 'Tinhte_Galleria':
        return lazySet(null, buildOp: galleria.buildOp);
      case 'Tinhte_PhotoCompare':
        return lazySet(null, buildOp: photoCompare.buildOp);
      case 'bbCodeBlock bbCodeQuote':
        return lazySet(null, isNotRenderable: true);
      case 'smilie':
        return lazySet(null, buildOp: smilieOp);
    }

    return super.parseElement(meta, e);
  }

  Widget _buildTextPadding(Widget widget) =>
      _checkIsText(widget) ? buildPadding(widget, _kTextPadding) : widget;

  bool _checkIsText(Widget w) {
    if (w == widget0) return false;
    if (w is _GalleriaGrid ||
        w is _PhotoCompareWidget ||
        w is AttachmentImageWidget ||
        w is WebView) return false;

    if (w is GestureDetector) return _checkIsText(w.child);
    if (w is InkWell) return _checkIsText(w.child);
    if (w is SingleChildRenderObjectWidget) return _checkIsText(w.child);

    return true;
  }
}

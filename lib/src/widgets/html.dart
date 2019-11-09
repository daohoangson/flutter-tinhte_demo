import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart'
    as core;
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
  final bool needBottomMargin;
  final TextStyle textStyle;

  TinhteHtmlWidget(
    this.html, {
    this.hyperlinkColor,
    Key key,
    this.needBottomMargin,
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext _) => LayoutBuilder(
        builder: (c, bc) => HtmlWidget(
          "<html><body>$html</body></html>",
          baseUrl: Uri.parse(configSiteRoot),
          bodyPadding: const EdgeInsets.only(top: kPostBodyPadding),
          factoryBuilder: (config) => TinhteWidgetFactory(
            config,
            maxWidth: bc.biggest.width * MediaQuery.of(c).devicePixelRatio,
            needBottomMargin: needBottomMargin,
          ),
          hyperlinkColor: hyperlinkColor,
          onTapUrl: (url) => launchLink(c, url),
          textStyle: textStyle,
          unsupportedWebViewWorkaroundForIssue37: true,
          webView: true,
        ),
      );
}

class TinhteWidgetFactory extends WidgetFactory {
  final double maxWidth;
  final bool needBottomMargin;

  var _isBuildingBody = 0;

  BuildOp _blockquoteOp;
  BuildOp _chrOp;
  BuildOp _smilieOp;
  BuildOp _webViewDataUriOp;

  Galleria _galleria;
  LbTrigger _lbTrigger;
  LinkExpander _linkExpander;
  PhotoCompare _photoCompare;

  TinhteWidgetFactory(
    HtmlWidgetConfig config, {
    this.maxWidth,
    this.needBottomMargin,
  }) : super(config);

  BuildOp get blockquoteOp {
    _blockquoteOp ??= BuildOp(
      onWidgets: (_, ws) => [
        Padding(
          child: Builder(
            builder: (context) => DecoratedBox(
              child: buildBody(ws),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: Theme.of(context).dividerColor,
                    width: 3,
                  ),
                ),
              ),
            ),
          ),
          padding: const EdgeInsets.all(kPostBodyPadding),
        ),
      ],
    );
    return _blockquoteOp;
  }

  BuildOp get chrOp {
    _chrOp ??= BuildOp(onWidgets: (meta, __) {
      final a = meta.domElement.attributes;
      final url = constructFullUrl(a['href']);
      if (url?.isEmpty != false) return null;

      return [buildWebView(url)];
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
          ..first.block.rebuildBits(
              (b) => b is DataBit ? b.rebuild(data: _kSmilies[title]) : b);
      },
    );
    return _smilieOp;
  }

  BuildOp get webViewDataUriOp {
    _webViewDataUriOp ??= BuildOp(
      onWidgets: (meta, _) => [
        buildWebView(Uri.dataFromString(
          """<!doctype html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width"></head><body>${meta.domElement.outerHtml}</body></html>""",
          encoding: Encoding.getByName('utf-8'),
          mimeType: 'text/html',
        ).toString())
      ],
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
  Widget buildImage(String url, {double height, String text, double width}) {
    final resizedUrl = getResizedUrl(
      apiUrl: url,
      boxWidth: maxWidth,
      imageHeight: height,
      imageWidth: width,
    );

    return super.buildImage(resizedUrl ?? url,
        height: height, text: text, width: width);
  }

  @override
  List<Widget> fixOverlappingSpacings(List<Widget> widgets) {
    var fixed = super.fixOverlappingSpacings(widgets);
    if (_isBuildingBody == 0 || fixed?.isNotEmpty != true) return fixed;

    final lastIsText = _checkIsText(fixed.last);
    fixed = fixed.map(_buildTextPadding).toList();

    if (lastIsText || needBottomMargin == true) {
      fixed.add(SizedBox(height: kPostBodyPadding));
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
          return lazySet(null,
              buildOp: lbTrigger.prepareBuildOpForATag(meta, e));
        }

        if (e.classes.contains('LinkExpander') &&
            e.classes.contains('expanded')) {
          return lazySet(null, buildOp: linkExpander.buildOp);
        }
        break;
      case 'blockquote':
        return lazySet(null, buildOp: blockquoteOp);
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
      case 'bdImage_attachImage':
        return lazySet(null, buildOp: lbTrigger.buildOp);
      case 'smilie':
        return lazySet(null, buildOp: smilieOp);
    }

    return super.parseElement(meta, e);
  }

  Widget _buildTextPadding(Widget widget) =>
      _checkIsText(widget) ? buildPadding(widget, _kTextPadding) : widget;

  bool _checkIsText(Widget widget) => widget is WidgetPlaceholder<TextBlock>;
}

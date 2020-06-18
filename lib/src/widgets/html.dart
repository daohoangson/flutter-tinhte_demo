import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:html/dom.dart' as dom;
import 'package:html_unescape/html_unescape.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:tinhte_demo/src/config.dart';
import 'package:tinhte_demo/src/constants.dart';
import 'package:tinhte_demo/src/intl.dart';
import 'package:tinhte_demo/src/link.dart';
import 'package:tinhte_demo/src/widgets/image.dart';
import 'package:url_launcher/url_launcher.dart';

part 'html/galleria.dart';
part 'html/link_expander.dart';
part 'html/lb_trigger.dart';
part 'html/photo_compare.dart';
part 'html/youtube.dart';

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
    this.needBottomMargin,
    this.textStyle,
  });

  bool get enableCaching {
    var skipCaching = false;
    assert(skipCaching = true);
    return !skipCaching;
  }

  @override
  Widget build(BuildContext _) => LayoutBuilder(
        builder: (c, bc) => HtmlWidget(
          "<html><body>$html</body></html>",
          baseUrl: Uri.parse(configSiteRoot),
          buildAsync: false,
          enableCaching: enableCaching,
          factoryBuilder: () => TinhteWidgetFactory(
            devicePixelRatio: MediaQuery.of(c).devicePixelRatio,
            deviceWidth: bc.biggest.width,
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
  final double devicePixelRatio;
  final double deviceWidth;
  final bool needBottomMargin;

  BuildOp _blockquoteOp;
  BuildOp _chrOp;
  BuildOp _metaBbCodeOp;
  BuildOp _smilieOp;
  BuildOp _webViewDataUriOp;

  Galleria _galleria;
  LbTrigger _lbTrigger;
  LinkExpander _linkExpander;
  PhotoCompare _photoCompare;

  TinhteWidgetFactory({
    this.devicePixelRatio,
    this.deviceWidth,
    this.needBottomMargin,
  });

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
    _chrOp ??= BuildOp(
      defaultStyles: (_, __) => ['margin', '0.5em 0'],
      onWidgets: (meta, __) {
        final a = meta.domElement.attributes;
        final url = constructFullUrl(a['href']);
        if (url?.isEmpty != false) return null;

        final youtubeId = a.containsKey('data-chr-thumbnail')
            ? RegExp(r'^https://img.youtube.com/vi/([^/]+)/0.jpg$')
                .firstMatch(a['data-chr-thumbnail'])
                ?.group(1)
            : null;

        final contents = youtubeId != null
            ? YouTubeWidget(
                youtubeId,
                lowresThumbnailUrl: a['data-chr-thumbnail'],
              )
            : buildWebView(url);

        return [contents];
      },
    );
    return _chrOp;
  }

  BuildOp get metaBbCodeOp {
    _metaBbCodeOp ??= BuildOp(
      onChild: (meta, e) =>
          (e.localName == 'span' && !e.classes.contains('value'))
              ? meta.isNotRenderable = true
              : null,
    );
    return _metaBbCodeOp;
  }

  BuildOp get smilieOp {
    _smilieOp ??= BuildOp(
      onPieces: (meta, pieces) {
        final a = meta.domElement.attributes;
        if (!a.containsKey('data-title')) return pieces;
        final title = a['data-title'];
        if (!_kSmilies.containsKey(title)) return pieces;

        final text = pieces.first.text;
        for (final bit in List.unmodifiable(text.bits)) {
          bit.detach();
        }
        text.addText(_kSmilies[title]);

        return pieces;
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
    final WidgetPlaceholder placeholder = super.buildBody(children);
    placeholder.wrapWith(_buildTextPadding);
    return placeholder;
  }

  @override
  Widget buildImage(String url, {double height, String text, double width}) {
    final resizedUrl = getResizedUrl(
      apiUrl: url,
      boxWidth: devicePixelRatio * deviceWidth,
      imageHeight: height,
      imageWidth: width,
    );

    return super.buildImage(resizedUrl ?? url,
        height: height, text: text, width: width);
  }

  @override
  void parseTag(NodeMetadata meta, String tag, Map<dynamic, String> attrs) {
    final clazz = attrs.containsKey('class') ? attrs['class'] : '';
    switch (tag) {
      case 'a':
        if (attrs.containsKey('data-chr') && attrs.containsKey('href')) {
          meta.op = chrOp;
          return;
        }

        if (clazz.contains('LinkExpander') && clazz.contains('expanded')) {
          meta.op = linkExpander.buildOp;
          return;
        }

        if (clazz.contains('LbTrigger') &&
            attrs.containsKey('data-height') &&
            attrs.containsKey('data-permalink') &&
            attrs.containsKey('data-width')) {
          meta.op = lbTrigger.prepareThumbnailOp(attrs);
          return;
        }
        break;
      case 'blockquote':
        meta.op = blockquoteOp;
        return;
      case 'div':
        if (clazz.contains('LinkExpander') && clazz.contains('is-oembed')) {
          meta.op = linkExpander.oembedOp;
          return;
        }
        break;
      case 'ul':
        if (clazz.contains('Tinhte_Galleria')) {
          meta.op = galleria.buildOp;
          return;
        }
        break;
      case 'script':
        if (attrs.containsKey('src') &&
            attrs['src'] == 'https://e.infogr.am/js/embed.js') {
          meta.op = webViewDataUriOp;
          return;
        }
        break;
      case 'span':
        if (clazz.contains('bdImage_attachImage')) {
          meta.op = lbTrigger.fullOp;
          return;
        }
        if (clazz.contains('metaBbCode')) {
          meta.op = metaBbCodeOp;
          return;
        }

        if (clazz.contains('Tinhte_PhotoCompare')) {
          meta.op = photoCompare.buildOp;
          return;
        }

        if (clazz.contains('smilie')) {
          meta.op = smilieOp;
          return;
        }
        break;
    }

    return super.parseTag(meta, tag, attrs);
  }

  Iterable<Widget> _buildTextPadding(BuildContext _, Iterable<Widget> ws, __) {
    final output = <Widget>[SizedBox(height: kPostBodyPadding)];

    final last = ws.last;
    for (final widget in ws) {
      final isText = widget is RichText ||
          (widget is ImageLayout &&
              widget.width != null &&
              widget.width < deviceWidth);
      output.add(isText ? buildPadding(widget, _kTextPadding) : widget);

      if (widget == last && (isText || needBottomMargin == true)) {
        output.add(SizedBox(height: kPostBodyPadding));
      }
    }

    return output;
  }
}

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

Widget _buildSpacing(NodeMetadata meta) => core.SpacingPlaceholder(
    height: CssLength(0.5, unit: CssLengthUnit.em), tsb: meta.tsb);

class TinhteHtmlWidget extends StatelessWidget {
  final String html;
  final Color hyperlinkColor;
  final bool needBottomMargin;
  final String plainText;
  final TextStyle textStyle;

  TinhteHtmlWidget(
    this.html, {
    this.hyperlinkColor,
    this.needBottomMargin,
    this.plainText,
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
          bodyPadding: const EdgeInsets.all(0),
          buildAsyncBuilder: (_, snapshot) {
            if (snapshot.hasData) return snapshot.data;

            if (plainText != null)
              return Padding(
                padding: const EdgeInsets.all(kPostBodyPadding),
                child: Text(plainText),
              );

            return const Center(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: CircularProgressIndicator(),
              ),
            );
          },
          enableCaching: enableCaching,
          factoryBuilder: (config) => TinhteWidgetFactory(
            config,
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

  TinhteWidgetFactory(
    HtmlConfig config, {
    this.devicePixelRatio,
    this.deviceWidth,
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
              ? lazySet(null, isNotRenderable: true)
              : meta,
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
          return lazySet(null, buildOp: lbTrigger.prepareThumbnailOp(e));
        }

        if (e.classes.contains('LinkExpander') &&
            e.classes.contains('expanded')) {
          return lazySet(null, buildOp: linkExpander.buildOp);
        }
        break;
      case 'blockquote':
        return lazySet(null, buildOp: blockquoteOp);
      case 'div':
        if (e.classes.contains('LinkExpander') &&
            e.classes.contains('is-oembed')) {
          return lazySet(null, buildOp: linkExpander.oembedOp);
        }
        break;
      case 'script':
        if (e.attributes.containsKey('src') &&
            e.attributes['src'] == 'https://e.infogr.am/js/embed.js') {
          return lazySet(null, buildOp: webViewDataUriOp);
        }
        break;
      case 'span':
        if (e.classes.contains('metaBbCode')) {
          return lazySet(null, buildOp: metaBbCodeOp);
        }
        break;
    }

    switch (e.className) {
      case 'Tinhte_Galleria':
        return lazySet(null, buildOp: galleria.buildOp);
      case 'Tinhte_PhotoCompare':
        return lazySet(null, buildOp: photoCompare.buildOp);
      case 'bdImage_attachImage':
        return lazySet(null, buildOp: lbTrigger.fullOp);
      case 'smilie':
        return lazySet(null, buildOp: smilieOp);
    }

    return super.parseElement(meta, e);
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

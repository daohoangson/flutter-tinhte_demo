import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
// ignore: implementation_imports
import 'package:flutter_widget_from_html_core/src/internal/css_sizing.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:the_app/src/config.dart';
import 'package:the_app/src/constants.dart';
import 'package:the_app/src/intl.dart';
import 'package:the_app/src/link.dart';
import 'package:the_app/src/widgets/image.dart';
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
  final TextStyle textStyle;

  TinhteHtmlWidget(
    this.html, {
    this.hyperlinkColor,
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
          baseUrl: Uri.parse(config.siteRoot),
          buildAsync: false,
          enableCaching: enableCaching,
          factoryBuilder: () => TinhteWidgetFactory(
            devicePixelRatio: MediaQuery.of(c).devicePixelRatio,
            deviceWidth: bc.biggest.width,
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

  BuildOp _blockquoteOp;
  BuildOp _chrOp;
  BuildOp _metaBbCodeOp;
  BuildOp _smilieOp;
  BuildOp _webViewDataUriOp;

  LbTrigger _lbTrigger;
  PhotoCompare _photoCompare;

  TinhteWidgetFactory({
    this.devicePixelRatio,
    this.deviceWidth,
  });

  BuildOp get blockquoteOp {
    _blockquoteOp ??= BuildOp(
      onWidgets: (meta, widgets) => [
        buildColumnPlaceholder(meta, widgets)
          ..wrapWith(
            (context, child) => Padding(
              child: DecoratedBox(
                child: child,
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: Theme.of(context).dividerColor,
                      width: 3,
                    ),
                  ),
                ),
              ),
              padding: const EdgeInsets.all(kPostBodyPadding),
            ),
          ),
      ],
    );
    return _blockquoteOp;
  }

  BuildOp get chrOp {
    _chrOp ??= BuildOp(
      defaultStyles: (_) => {'margin': '0.5em 0'},
      onWidgets: (meta, __) {
        final a = meta.element.attributes;
        final url = urlFull(a['href']);
        if (url?.isEmpty != false) return null;

        final youtubeId = !Platform.isIOS && a.containsKey('data-chr-thumbnail')
            ? RegExp(r'^https://img.youtube.com/vi/([^/]+)/0.jpg$')
                .firstMatch(a['data-chr-thumbnail'])
                ?.group(1)
            : null;

        final contents = youtubeId != null
            ? YouTubeWidget(
                youtubeId,
                lowresThumbnailUrl: a['data-chr-thumbnail'],
              )
            : buildWebView(meta, url);

        return [contents];
      },
    );
    return _chrOp;
  }

  BuildOp get metaBbCodeOp {
    _metaBbCodeOp ??= BuildOp(
      onChild: (meta) => (meta.element.localName == 'span' &&
              !meta.element.classes.contains('value'))
          ? meta.isNotRenderable = true
          : null,
    );
    return _metaBbCodeOp;
  }

  BuildOp get smilieOp {
    _smilieOp ??= BuildOp(
      onPieces: (meta, pieces) {
        final a = meta.element.attributes;
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
        buildWebView(
            meta,
            Uri.dataFromString(
              """<!doctype html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width"></head><body>${meta.element.outerHtml}</body></html>""",
              encoding: Encoding.getByName('utf-8'),
              mimeType: 'text/html',
            ).toString())
      ],
    );
    return _webViewDataUriOp;
  }

  LbTrigger get lbTrigger {
    _lbTrigger ??= LbTrigger(wf: this);
    return _lbTrigger;
  }

  PhotoCompare get photoCompare {
    _photoCompare ??= PhotoCompare(this);
    return _photoCompare;
  }

  @override
  WidgetPlaceholder buildColumnPlaceholder(
    BuildMetadata meta,
    Iterable<Widget> children, {
    bool trimMarginVertical = false,
  }) {
    if (_isBuildingText > 0) {
      if (_isBuildingText != 1) print('_isBuildingText=$_isBuildingText');
      children = List.from(children.map((child) {
        if (child is WidgetPlaceholder<TextBits>)
          child.wrapWith((_, w) => _TextPadding(w));

        return child;
      }));
    }

    final built = super.buildColumnPlaceholder(meta, children,
        trimMarginVertical: trimMarginVertical);

    if (trimMarginVertical) {
      built.wrapWith((_, child) {
        final last = _lastOf(child);

        return Padding(
          child: child,
          padding: EdgeInsets.only(
            top: kPostBodyPadding,
            bottom: last is _TextPadding || last is WidgetPlaceholder<TextBits>
                ? kPostBodyPadding
                : 0.0,
          ),
        );
      });
    }

    return built;
  }

  @override
  Widget buildImage(BuildMetadata meta, Object provider, ImageMetadata image) {
    if (image.sources?.first?.width == null) {
      final attrs = meta.element.attributes;
      if (attrs.containsKey('data-height') && attrs.containsKey('data-width')) {
        final resizedUrl = getResizedUrl(
          apiUrl: image.sources.first.url,
          boxWidth: devicePixelRatio * deviceWidth,
          imageHeight: double.tryParse(attrs['data-height']),
          imageWidth: double.tryParse(attrs['data-width']),
        );
        if (resizedUrl != null)
          provider = imageProvider(ImageSource(resizedUrl));
      }
    }

    return super.buildImage(meta, provider, image);
  }

  var _isBuildingText = 0;
  @override
  WidgetPlaceholder buildText(BuildMetadata meta, TextBits text) {
    _isBuildingText++;
    final built = super.buildText(meta, text);
    _isBuildingText--;

    return built;
  }

  @override
  void parse(BuildMetadata meta) {
    final attrs = meta.element.attributes;
    final classes = meta.element.classes;
    switch (meta.element.localName) {
      case 'a':
        if (attrs.containsKey('data-chr') && attrs.containsKey('href')) {
          meta.register(chrOp);
          return;
        }

        if (classes.contains('LinkExpander') && classes.contains('expanded')) {
          meta.register(LinkExpander(this, meta).op);
          return;
        }

        if (classes.contains('LbTrigger') &&
            attrs.containsKey('data-height') &&
            attrs.containsKey('data-permalink') &&
            attrs.containsKey('data-width')) {
          meta.register(lbTrigger.prepareThumbnailOp(attrs));
          return;
        } else if (classes.contains('js-lbImage')) {
          // [ATTACH] (thumbnail)
          meta.register(lbTrigger.prepareXenForo2Op(attrs, 'href'));
          return;
        }
        break;
      case 'blockquote':
        meta.register(blockquoteOp);
        return;
      case 'div':
        if (classes.contains('LinkExpander') && classes.contains('is-oembed')) {
          meta.register(LinkExpander.getOembedOp());
          return;
        }
        break;
      case 'img':
        if (attrs.containsKey('data-height')) {
          meta['height'] = '${attrs["data-height"]}px';
        }
        if (attrs.containsKey('data-width')) {
          meta['width'] = '${attrs["data-width"]}px';
        }

        if (classes.contains('bbImage') &&
            meta.element.parent?.classes?.contains('js-lbImage') == false) {
          // [ATTACH=full]
          meta.isBlockElement = true;
          meta.register(lbTrigger.prepareXenForo2Op(attrs, 'src'));
        }
        break;
      case 'ul':
        if (classes.contains('Tinhte_Galleria')) {
          meta.register(Galleria(this, meta).op);
          return;
        }
        break;
      case 'script':
        if (attrs.containsKey('src') &&
            attrs['src'] == 'https://e.infogr.am/js/embed.js') {
          meta.register(webViewDataUriOp);
          return;
        }
        break;
      case 'span':
        if (classes.contains('bdImage_attachImage')) {
          meta.register(lbTrigger.fullOp);
          return;
        }
        if (classes.contains('metaBbCode')) {
          meta.register(metaBbCodeOp);
          return;
        }

        if (classes.contains('Tinhte_PhotoCompare')) {
          meta.register(photoCompare.buildOp);
          return;
        }

        if (classes.contains('smilie')) {
          meta.register(smilieOp);
          return;
        }
        break;
    }

    return super.parse(meta);
  }

  @override
  void reset(State state) {
    this._lbTrigger = null;

    super.reset(state);
  }
}

class _TextPadding extends StatelessWidget {
  final Widget child;

  const _TextPadding(this.child, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      Padding(child: child, padding: _kTextPadding);
}

Widget _lastOf(Widget widget) {
  if (widget is Column) {
    return _lastOf(widget.children.last);
  }

  return widget;
}

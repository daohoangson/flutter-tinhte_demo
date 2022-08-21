import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:fwfh_webview/fwfh_webview.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:http/http.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:the_app/src/api.dart';
import 'package:the_app/src/config.dart';
import 'package:the_app/src/constants.dart';
import 'package:the_app/src/intl.dart';
import 'package:the_app/src/link.dart';
import 'package:the_app/src/widgets/image.dart';
import 'package:the_app/src/widgets/video_player.dart';
import 'package:url_launcher/url_launcher.dart';

part 'html/chr.dart';
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

class TinhteHtmlWidget extends StatelessWidget {
  final String html;
  final double textPadding;
  final TextStyle? textStyle;

  TinhteHtmlWidget(
    this.html, {
    this.textPadding = kPostBodyPadding,
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
            textPadding: textPadding,
          ),
          onTapUrl: (url) => launchLink(c, url),
          textStyle: textStyle,
        ),
      );
}

class TinhteWidgetFactory extends WidgetFactory {
  final double devicePixelRatio;
  final double deviceWidth;
  final double textPadding;

  BuildOp? _blockquoteOp;
  BuildOp? _chrOp;
  BuildOp? _metaBbCodeOp;
  BuildOp? _smilieOp;
  BuildOp? _webViewDataUriOp;

  LbTrigger? _lbTrigger;
  PhotoCompare? _photoCompare;

  TinhteWidgetFactory({
    required this.devicePixelRatio,
    required this.deviceWidth,
    required this.textPadding,
  });

  BuildOp get blockquoteOp {
    return _blockquoteOp ??= BuildOp(
      onWidgets: (meta, widgets) {
        final column = buildColumnPlaceholder(meta, widgets)?.wrapWith(
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
            padding: EdgeInsets.all(textPadding),
          ),
        );

        return [if (column != null) column];
      },
    );
  }

  BuildOp get chrOp {
    return _chrOp ??= Chr(this).op;
  }

  BuildOp get metaBbCodeOp {
    return _metaBbCodeOp ??= BuildOp(
      onChild: (meta) => (meta.element.localName == 'span' &&
              !meta.element.classes.contains('value'))
          ? meta['display'] = 'none'
          : null,
    );
  }

  BuildOp get smilieOp {
    return _smilieOp ??= BuildOp(
      onTree: (meta, tree) {
        final a = meta.element.attributes;
        final title = a['data-title'];
        if (title == null) return;
        final smilie = _kSmilies[title];
        if (smilie == null) return;
        final parentTree = tree.parent;
        if (parentTree == null) return;

        // TODO: use `replaceWith` when it comes back in v0.9
        TextBit(parentTree, smilie).insertBefore(tree);
        tree.detach();
      },
    );
  }

  BuildOp get webViewDataUriOp {
    return _webViewDataUriOp ??= BuildOp(
      onWidgets: (meta, _) {
        final webView = buildWebView(
          meta,
          Uri.dataFromString(
            """<!doctype html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width"></head><body>${meta.element.outerHtml}</body></html>""",
            encoding: Encoding.getByName('utf-8'),
            mimeType: 'text/html',
          ).toString(),
        );
        return [if (webView != null) webView];
      },
    );
  }

  @override
  bool get webView => true;

  LbTrigger get lbTrigger {
    return _lbTrigger ??= LbTrigger(wf: this);
  }

  PhotoCompare get photoCompare {
    return _photoCompare ??= PhotoCompare(this);
  }

  @override
  Widget buildBodyWidget(BuildContext context, Widget child) {
    child = Padding(
      child: child,
      padding: EdgeInsets.symmetric(vertical: textPadding),
    );

    return super.buildBodyWidget(context, child);
  }

  @override
  Widget? buildImageWidget(BuildMetadata meta, ImageSource source) {
    String? resizedUrl;
    final width = source.width;
    final height = source.height;
    if (width != null && height != null) {
      resizedUrl = getResizedUrl(
        apiUrl: source.url,
        boxWidth: devicePixelRatio * deviceWidth,
        imageHeight: height,
        imageWidth: width,
      );
    }

    ImageSource src = source;
    if (resizedUrl != null) {
      // TODO: switch to `ImageSource.copyWith` when it's available
      src = ImageSource(resizedUrl, height: src.height, width: src.width);
    }

    return super.buildImageWidget(meta, src);
  }

  @override
  Widget? buildText(BuildMetadata meta, TextStyleHtml tsh, InlineSpan text) {
    var built = super.buildText(meta, tsh, text);

    if (built != null) {
      built = Padding(
        child: built,
        padding: EdgeInsets.symmetric(horizontal: textPadding),
      );
    }

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
          final thumbnailOp = lbTrigger.prepareThumbnailOp(attrs);
          if (thumbnailOp != null) {
            meta.register(thumbnailOp);
          }
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
        if (classes.contains('bdPostTree_ParentQuote')) {
          meta['display'] = 'none';
          return;
        }
        break;
      case 'img':
        final height = attrs['data-height'];
        if (height != null) {
          attrs['height'] = height;
        }
        final width = attrs['data-width'];
        if (width != null) {
          attrs['width'] = width;
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

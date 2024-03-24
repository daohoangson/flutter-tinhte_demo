part of '../html.dart';

class Chr {
  final WidgetFactory wf;

  Chr(this.wf);

  BuildOp get op => BuildOp(
        defaultStyles: (_) => {'margin': '0.5em 0'},
        onWidgets: (meta, __) {
          final a = meta.element.attributes;
          final url = wf.urlFull(a['href'] ?? '') ?? '';
          if (url.isEmpty) return null;

          final chrThumbnail = a['data-chr-thumbnail'] ?? '';
          final youtubeId =
              RegExp(r'^https://img.youtube.com/vi/([^/]+)/0.jpg$')
                  .firstMatch(chrThumbnail)
                  ?.group(1);

          final contents = youtubeId != null
              ? YouTubeWidget(youtubeId, lowresThumbnailUrl: chrThumbnail)
              : _ChrWidget(meta: meta, url: url, wf: wf);

          return [contents];
        },
      );
}

class _ChrWidget extends StatefulWidget {
  final BuildMetadata meta;
  final String url;
  final WidgetFactory wf;

  const _ChrWidget({
    super.key,
    required this.meta,
    required this.url,
    required this.wf,
  });

  @override
  State<_ChrWidget> createState() => _ChrState();
}

class _ChrState extends State<_ChrWidget> {
  var _isFinalUrl = false;
  var _isSendingRequest = false;
  late String _url;

  bool get isToolsChr => _url.contains('tools/chr') == true;

  @override
  void initState() {
    super.initState();
    _url = widget.url;
  }

  @override
  Widget build(BuildContext context) {
    if (!_isFinalUrl) {
      _sendRequest();
    }

    return _isFinalUrl
        ? (widget.wf.buildWebView(widget.meta, _url) ??
            const AspectRatio(
              aspectRatio: 16 / 9,
              child: widget0,
            ))
        : const AspectRatio(
            aspectRatio: 16 / 9,
            child: AdaptiveProgressIndicator(),
          );
  }

  void _sendRequest() {
    if (_isSendingRequest) return;
    setState(() => _isSendingRequest = true);

    final apiAuth = ApiAuth.of(context);
    apiAuth.api.sendRequest('GET', _url).then(
      (value) {
        final location = value.headers['location'];
        if (value is Response && value.statusCode == 301 && location != null) {
          // this works around Android WebView calling our app after 2 redirects
          // (because of the domain association)
          _url = location;
          debugPrint('Unwrapped CHR url: $_url');
        }

        setState(() => _isFinalUrl = true);
      },
    ).whenComplete(() => setState(() => _isSendingRequest = false));
  }
}

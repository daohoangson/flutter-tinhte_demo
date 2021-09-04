part of '../html.dart';

class Chr {
  final WidgetFactory wf;

  Chr(this.wf);

  BuildOp get op => BuildOp(
        defaultStyles: (_) => {'margin': '0.5em 0'},
        onWidgets: (meta, __) {
          final a = meta.element.attributes;
          final url = wf.urlFull(a['href']);
          if (url?.isEmpty != false) return null;

          final youtubeId =
              !Platform.isIOS && a.containsKey('data-chr-thumbnail')
                  ? RegExp(r'^https://img.youtube.com/vi/([^/]+)/0.jpg$')
                      .firstMatch(a['data-chr-thumbnail'])
                      ?.group(1)
                  : null;

          final contents = youtubeId != null
              ? YouTubeWidget(
                  youtubeId,
                  lowresThumbnailUrl: a['data-chr-thumbnail'],
                )
              : _ChrWidget(meta: meta, url: url, wf: wf);

          return [contents];
        },
      );
}

class _ChrWidget extends StatefulWidget {
  final BuildMetadata meta;
  final String url;
  final WidgetFactory wf;

  const _ChrWidget({Key key, this.meta, this.url, this.wf}) : super(key: key);

  @override
  State<_ChrWidget> createState() => _ChrState();
}

class _ChrState extends State<_ChrWidget> {
  var _isFinalUrl = false;
  var _isSendingRequest = false;
  String _url;

  bool get isToolsChr => _url?.contains('tools/chr') == true;

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

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: _isFinalUrl
          ? widget.wf.buildWebView(widget.meta, _url)
          : CircularProgressIndicator.adaptive(),
    );
  }

  void _sendRequest() {
    if (_isSendingRequest) return;
    setState(() => _isSendingRequest = true);

    final apiAuth = ApiAuth.of(context);
    apiAuth.api.sendRequest('GET', _url).then(
      (value) {
        if (value is Response && value.statusCode == 301) {
          // this is needed because Android WebView opens our app after 2 redirects
          // (because of the domain association)
          _url = value.headers['location'];
          print('Unwrapped CHR url: $_url');
        }

        setState(() => _isFinalUrl = true);
      },
    ).whenComplete(() => setState(() => _isSendingRequest = false));
  }
}

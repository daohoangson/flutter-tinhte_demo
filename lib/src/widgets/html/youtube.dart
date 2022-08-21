part of '../html.dart';

final _kMetaTag = RegExp(r'<meta property="([^"]+)" content="([^"]+)">');
const _kOgImage = 'og:image';
const _kOgImageHeight = 'og:image:height';
const _kOgImageWidth = 'og:image:image';
const _kOgTitle = 'og:title';

class YouTubeWidget extends StatefulWidget {
  final String id;
  final String lowresThumbnailUrl;

  const YouTubeWidget(
    this.id, {
    Key? key,
    required this.lowresThumbnailUrl,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _YouTubeState();
}

class _YouTubeState extends State<YouTubeWidget> {
  String get videoUrl => "https://www.youtube.com/watch?v=${widget.id}";

  double _aspectRatio = 16 / 9;
  late String _thumbnailUrl;
  String? _title;

  @override
  void initState() {
    super.initState();

    _thumbnailUrl = widget.lowresThumbnailUrl;
    _fetch();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, bc) => GestureDetector(
          child: Stack(
            children: <Widget>[
              _buildThumbnail(),
              _buildTitle(bc),
              Positioned.fill(child: _buildYouTubeLogo(bc.biggest.width / 2))
            ],
          ),
          onTap: () => launch(videoUrl),
        ),
      );

  Widget _buildThumbnail() => AspectRatio(
        aspectRatio: _aspectRatio,
        child: Container(
          child: Opacity(
            child: Image(
              image: CachedNetworkImageProvider(_thumbnailUrl),
              fit: BoxFit.cover,
            ),
            opacity: .8,
          ),
          decoration: BoxDecoration(color: Colors.black),
        ),
      );

  Widget _buildTitle(BoxConstraints bc) {
    final fontSize = bc.biggest.width / 24.0;
    final scopedTitle = _title;
    if (scopedTitle == null) return widget0;

    return Container(
      alignment: Alignment.topLeft,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black, Colors.transparent],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
      width: double.infinity,
      child: Text(
        scopedTitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: const Color.fromRGBO(241, 241, 241, 1),
          fontSize: fontSize,
        ),
        textScaleFactor: 1,
      ),
    );
  }

  Widget _buildYouTubeLogo(double width) => Center(
        child: Image.asset(
          'assets/yt_logo_rgb_dark.png',
          width: width,
        ),
      );

  void _fetch() async {
    final file = await DefaultCacheManager().getSingleFile(videoUrl);
    final html = await file.readAsString();
    final unescape = HtmlUnescape();
    final metaTags = Map.fromEntries(_kMetaTag.allMatches(html).map(
        (match) => MapEntry(match.group(1), unescape.convert(match.group(2)!))));
    if (!metaTags.containsKey(_kOgImage)) return;

    double aspectRatio = _aspectRatio;
    if (metaTags.containsKey(_kOgImageWidth) &&
        metaTags.containsKey(_kOgImageHeight)) {
      final width = double.tryParse(metaTags[_kOgImageWidth] ?? '');
      final height = double.tryParse(metaTags[_kOgImageHeight] ?? '');
      if (width != null && height != null) {
        aspectRatio = width / height;
      }
    }

    if (!mounted) return;
    setState(() {
      _aspectRatio = aspectRatio;
      if (metaTags.containsKey(_kOgTitle)) _title = metaTags[_kOgTitle];
    });

    final thumbnailUrl = metaTags[_kOgImage];
    if (thumbnailUrl == null) return;

    await precacheImage(CachedNetworkImageProvider(thumbnailUrl), context);
    if (!mounted) return;
    setState(() => _thumbnailUrl = thumbnailUrl);
  }
}

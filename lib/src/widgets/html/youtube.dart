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
    Key key,
    this.lowresThumbnailUrl,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _YouTubeState();
}

class _YouTubeState extends State<YouTubeWidget> {
  String get videoUrl => "https://www.youtube.com/watch?v=${widget.id}";

  double _aspectRatio = 16 / 9;
  String _thumbnailUrl;
  String _title;

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
              _title != null
                  ? Align(
                      alignment: Alignment.topLeft,
                      child: _buildTitle(bc.biggest.width / 24),
                    )
                  : const SizedBox.shrink(),
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

  Widget _buildTitle(double fontSize) => Container(
        child: Text(
          _title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: const Color.fromRGBO(241, 241, 241, 1),
            fontSize: fontSize,
          ),
          textScaleFactor: 1,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black, Colors.transparent],
          ),
        ),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
        width: double.infinity,
      );

  Widget _buildYouTubeLogo(double width) => Center(
        child: Image.asset(
          'assets/yt_logo_rgb_dark.png',
          width: width,
        ),
      );

  void _fetch() async {
    final file = await DefaultCacheManager().getSingleFile(videoUrl);
    final html = await file.readAsString();
    final metaTags = Map.fromEntries(_kMetaTag
        .allMatches(html)
        .map((match) => MapEntry(match.group(1), match.group(2))));
    if (!metaTags.containsKey(_kOgImage)) return;

    double aspectRatio = _aspectRatio;
    if (metaTags.containsKey(_kOgImageWidth) &&
        metaTags.containsKey(_kOgImageHeight)) {
      final width = double.tryParse(metaTags[_kOgImageWidth]);
      final height = double.tryParse(metaTags[_kOgImageHeight]);
      if (width != null && height != null) {
        aspectRatio = width / height;
      }
    }

    setState(() {
      _aspectRatio = aspectRatio;
      _thumbnailUrl = metaTags[_kOgImage];

      if (metaTags.containsKey(_kOgTitle)) _title = metaTags[_kOgTitle];
    });
  }
}

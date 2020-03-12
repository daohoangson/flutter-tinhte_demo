part of '../html.dart';

final kYouTubeOgImage = RegExp(r'<meta property="og:image" content="([^"]+)">');
final kYouTubeWidth =
    RegExp(r'<meta property="og:image:width" content="(\d+)">');
final kYouTubeHeight =
    RegExp(r'<meta property="og:image:height" content="(\d+)">');
const kYouTubeRed = const Color.fromRGBO(204, 24, 30, 1.0);

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

  @override
  void initState() {
    super.initState();

    _thumbnailUrl = widget.lowresThumbnailUrl;
    _fetch();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        child: Stack(
          children: <Widget>[
            AspectRatio(
              aspectRatio: _aspectRatio,
              child: buildCachedNetworkImage(_thumbnailUrl),
            ),
            Positioned.fill(
              child: Center(
                child: Opacity(
                  child: Icon(
                    Icons.play_arrow,
                    color: kYouTubeRed,
                    size: 75,
                  ),
                  opacity: .75,
                ),
              ),
            ),
          ],
        ),
        onTap: () => launch(videoUrl),
      );

  void _fetch() async {
    final file = await DefaultCacheManager().getSingleFile(videoUrl);
    final html = await file.readAsString();
    final match = kYouTubeOgImage.firstMatch(html);
    if (match == null) return;

    double aspectRatio = _aspectRatio;
    final widthMatch = kYouTubeWidth.firstMatch(html);
    final heightMatch = kYouTubeHeight.firstMatch(html);
    if (widthMatch != null && heightMatch != null) {
      final width = double.tryParse(widthMatch.group(1));
      final height = double.tryParse(heightMatch.group(1));
      if (width != null && height != null) {
        aspectRatio = width / height;
      }
    }

    setState(() {
      _aspectRatio = aspectRatio;
      _thumbnailUrl = match.group(1);
    });
  }
}

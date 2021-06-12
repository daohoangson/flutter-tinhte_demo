import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayer extends StatefulWidget {
  final double aspectRatio;
  final String url;

  const VideoPlayer({
    @required this.aspectRatio,
    Key key,
    @required this.url,
  })  : assert(aspectRatio != null),
        assert(url != null),
        super(key: key);

  @override
  State<VideoPlayer> createState() => _VideoState();
}

class _VideoState extends State<VideoPlayer> {
  VideoPlayerController _videoPlayerController;
  ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    initializePlayer();
  }

  void initializePlayer() async {
    _videoPlayerController = VideoPlayerController.network(widget.url);

    await _videoPlayerController.initialize();

    if (!mounted) return;
    _chewieController = ChewieController(
      aspectRatio: widget.aspectRatio,
      autoPlay: true,
      looping: true,
      videoPlayerController: _videoPlayerController,
    );
    setState(() {});
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_chewieController?.videoPlayerController?.value?.isInitialized !=
        true) {
      return AspectRatio(
        aspectRatio: widget.aspectRatio,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: Chewie(
        controller: _chewieController,
      ),
    );
  }
}

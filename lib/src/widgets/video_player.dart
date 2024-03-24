import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:the_app/src/abstracts/progress_indicator.dart';
import 'package:video_player/video_player.dart';

class VideoPlayer extends StatefulWidget {
  final double aspectRatio;
  final bool autoPlay;
  final Uri uri;

  const VideoPlayer({
    required this.aspectRatio,
    required this.autoPlay,
    super.key,
    required this.uri,
  });

  @override
  State<VideoPlayer> createState() => _VideoState();
}

class _VideoState extends State<VideoPlayer> {
  late final VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    initializePlayer();
  }

  void initializePlayer() async {
    _videoPlayerController = VideoPlayerController.networkUrl(widget.uri);

    await _videoPlayerController.initialize();

    if (!mounted) return;
    _chewieController = ChewieController(
      aspectRatio: widget.aspectRatio,
      autoPlay: widget.autoPlay,
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
    if (_chewieController?.videoPlayerController.value.isInitialized != true) {
      return AspectRatio(
        aspectRatio: widget.aspectRatio,
        child: const AdaptiveProgressIndicator(),
      );
    }

    return AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: Chewie(
        controller: _chewieController!,
      ),
    );
  }
}

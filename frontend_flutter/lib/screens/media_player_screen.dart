import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

import '../theme/app_theme.dart';

/// Plays an education video or audio lesson from a URL (chewie controls over
/// video_player). Used by the Education Hub. For audio the same player is used —
/// it shows a control bar over a branded panel.
class MediaPlayerScreen extends StatefulWidget {
  final String url;
  final String title;
  final bool isAudio;
  const MediaPlayerScreen({super.key, required this.url, required this.title, this.isAudio = false});

  @override
  State<MediaPlayerScreen> createState() => _MediaPlayerScreenState();
}

class _MediaPlayerScreenState extends State<MediaPlayerScreen> {
  VideoPlayerController? _video;
  ChewieController? _chewie;
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final v = VideoPlayerController.networkUrl(Uri.parse(widget.url));
      await v.initialize();
      final c = ChewieController(
        videoPlayerController: v,
        autoPlay: true,
        looping: false,
        aspectRatio: widget.isAudio ? 16 / 9 : (v.value.aspectRatio == 0 ? 16 / 9 : v.value.aspectRatio),
        materialProgressColors: ChewieProgressColors(
          playedColor: AppColors.teal,
          handleColor: AppColors.tealDark,
          backgroundColor: AppColors.border,
          bufferedColor: AppColors.tealLight,
        ),
        placeholder: Container(color: Colors.black),
        errorBuilder: (ctx, msg) => _errorView(msg),
      );
      if (mounted) setState(() { _video = v; _chewie = c; });
    } catch (e) {
      if (mounted) setState(() => _error = 'This lesson could not be loaded. Please check your connection.');
    }
  }

  @override
  void dispose() {
    _chewie?.dispose();
    _video?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.title, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
      ),
      body: Center(
        child: _error != null
            ? _errorView(_error!)
            : (_chewie != null
                ? (widget.isAudio ? _audioShell() : Chewie(controller: _chewie!))
                : const CircularProgressIndicator(color: AppColors.teal)),
      ),
    );
  }

  Widget _audioShell() => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🎧', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(widget.title, textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
          ),
          const SizedBox(height: 24),
          AspectRatio(aspectRatio: 16 / 9, child: Chewie(controller: _chewie!)),
        ],
      );

  Widget _errorView(String msg) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.error_outline_rounded, color: Colors.white70, size: 48),
          const SizedBox(height: 12),
          Text(msg, textAlign: TextAlign.center, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14)),
        ]),
      );
}

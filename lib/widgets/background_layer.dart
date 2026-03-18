import 'dart:io';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:provider/provider.dart';
import '../models/app_settings.dart';

class BackgroundLayer extends StatefulWidget {
  const BackgroundLayer({super.key});

  @override
  State<BackgroundLayer> createState() => _BackgroundLayerState();
}

class _BackgroundLayerState extends State<BackgroundLayer> {
  Player? _player;
  VideoController? _videoController;
  String? _currentPath;

  @override
  void dispose() {
    _player?.dispose();
    super.dispose();
  }

  void _initVideo(String path) {
    _player?.dispose();
    _player = Player();
    _videoController = VideoController(_player!);

    _player!.setVolume(0);
    _player!.setPlaylistMode(PlaylistMode.loop);
    _player!.open(Media(path));
    _currentPath = path;
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    final bgPath = settings.backgroundPath;

    // No background set
    if (bgPath == null || bgPath.isEmpty) {
      _player?.dispose();
      _player = null;
      _currentPath = null;
      return const SizedBox.expand();
    }

    // Video background
    if (settings.isVideo) {
      if (_currentPath != bgPath) {
        // Defer init to avoid build-phase side effects
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _initVideo(bgPath);
            setState(() {});
          }
        });
      }

      if (_videoController == null) return const SizedBox.expand();

      return SizedBox.expand(
        child: Video(
          controller: _videoController!,
          fit: BoxFit.cover,
          controls: NoVideoControls,
        ),
      );
    }

    // Image background
    _player?.dispose();
    _player = null;
    _currentPath = null;

    return SizedBox.expand(
      child: Image.file(
        File(bgPath),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const SizedBox.expand(),
      ),
    );
  }
}
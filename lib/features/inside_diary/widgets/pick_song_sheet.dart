import 'package:flutter/material.dart';

import 'package:music_diary_new/core/models/song.dart';
import 'package:music_diary_new/core/theme/app_theme.dart';

import '../logic/pick_song_controller.dart';
import 'safe_asset_image.dart';

class PickSongSheet extends StatefulWidget {
  const PickSongSheet({super.key});

  @override
  State<PickSongSheet> createState() => _PickSongSheetState();
}

class _PickSongSheetState extends State<PickSongSheet> {
  late final PickSongController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PickSongController()
      ..addListener(_onControllerChanged)
      ..initialize();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Song> songs = _controller.songs;
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: const BoxDecoration(color: AppTheme.surface),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 46,
              height: 5,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            TextField(
              controller: _controller.searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search songs',
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.08),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: songs.length,
                itemBuilder: (context, index) {
                  final song = songs[index];
                  return ListTile(
                    onTap: () => Navigator.of(context).pop(song),
                    leading: SafeAssetImage(
                      asset: song.imageAsset,
                      width: 48,
                      height: 48,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    title: Text(song.title),
                    subtitle: Text(
                      '${song.artist} • ${song.album}',
                      style: const TextStyle(color: AppTheme.textSecondary),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onControllerChanged)
      ..dispose();
    super.dispose();
  }
}

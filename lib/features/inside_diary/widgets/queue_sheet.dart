import 'package:flutter/material.dart';

import 'package:music_diary_new/core/models/song.dart';
import 'package:music_diary_new/core/theme/app_theme.dart';

import 'safe_asset_image.dart';

/// Displays the current playback queue inside a rounded bottom sheet.
class QueueSheet extends StatelessWidget {
  const QueueSheet({
    super.key,
    required this.currentSongId,
    required this.songs,
  });

  final String currentSongId;
  final List<Song> songs;

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.6;
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Current queue',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.separated(
                    itemBuilder: (context, index) {
                      final song = songs[index];
                      final isCurrent = song.id == currentSongId;
                      return Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => Navigator.of(context).pop(song),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isCurrent
                                  ? AppTheme.accent.withValues(alpha: 0.2)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                SafeAssetImage(
                                  asset: song.imageAsset,
                                  width: 48,
                                  height: 48,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        song.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${song.artist} • ${song.album}',
                                        style: const TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Icon(
                                  isCurrent ? Icons.volume_up : Icons.play_arrow,
                                  size: 20,
                                  color:
                                      isCurrent ? AppTheme.accent : Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemCount: songs.length,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

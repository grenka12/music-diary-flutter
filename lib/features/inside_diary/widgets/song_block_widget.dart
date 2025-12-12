import 'package:flutter/material.dart';
import 'package:music_diary_new/core/models/song.dart';
import 'package:music_diary_new/core/theme/app_theme.dart';
import 'safe_asset_image.dart';

class SongBlockWidget extends StatelessWidget {
  final Song song;
  final bool isActive;
  final bool isPlaying;
  final VoidCallback onDelete;
  final VoidCallback onPlay;

  const SongBlockWidget({
    super.key,
    required this.song,
    required this.isActive,
    required this.isPlaying,
    required this.onDelete,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    final highlight = isActive ? AppTheme.accent : Colors.white.withValues(alpha: 0.05);
    final overlayOpacity = isActive ? (isPlaying ? 0.15 : 0.3) : 0.4;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: highlight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? AppTheme.accent.withValues(alpha: 0.6) : Colors.transparent,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onPlay,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SafeAssetImage(
                      asset: song.imageAsset,
                      width: 52,
                      height: 52,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: Colors.black.withValues(alpha: overlayOpacity),
                      ),
                      child: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${song.artist} • ${song.album}',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.close, size: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:music_diary_new/core/data/json_file_repo.dart';
import 'package:music_diary_new/core/theme/app_theme.dart';
import 'package:music_diary_new/features/home/widgets/glass_card.dart';

/// Основний елемент списку в щоденнику
class EntryTile extends StatelessWidget {
  final CachedEntry entry;
  final double animationDelay;
  final VoidCallback onTap;
  final Function(Offset) onLongPress;

  const EntryTile({
    super.key,
    required this.entry,
    required this.animationDelay,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Interval(animationDelay.clamp(0, 0.8), 1, curve: Curves.easeOutCubic),
      builder: (_, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, (1 - value) * 24),
          child: child,
        ),
      ),
      child: GlassCard(
        onTap: onTap,
        onLongPressStart: (details) => onLongPress(details.globalPosition),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            _EntryPreview(coverImageAsset: entry.coverImageAsset),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    entry.description ?? '',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      letterSpacing: 0.1,
                    ),
                  ),

                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

/// Превʼю обкладинки (або дефолтна іконка) для запису
class _EntryPreview extends StatelessWidget {
  const _EntryPreview({
    required this.coverImageAsset,
  });

  final String? coverImageAsset;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: RadialGradient(
          radius: 1.2,
          colors: [
            AppColors.accent.withValues(alpha: .35),
            Colors.transparent
          ],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: coverImageAsset == null
            ? _defaultIcon()
            : coverImageAsset!.startsWith('http')
                ? CachedNetworkImage(
                    imageUrl: coverImageAsset!,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => _loadingPlaceholder(),
                    errorWidget: (_, __, ___) => _defaultIcon(),
                  )
                : Image.asset(
                    coverImageAsset!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _defaultIcon(),
                  ),
      ),
    );
  }

  Widget _defaultIcon() => Container(
        color: Colors.white.withValues(alpha: 0.05),
        child: const Icon(Icons.music_note, color: AppColors.textPrimary),
      );

  Widget _loadingPlaceholder() => Container(
        color: Colors.white.withValues(alpha: 0.05),
        alignment: Alignment.center,
        child: const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
}

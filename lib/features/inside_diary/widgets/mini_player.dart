import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:music_diary_new/core/models/song.dart';
import 'package:music_diary_new/core/theme/app_theme.dart';

class MiniPlayer extends StatelessWidget {
  final Song song;
  final bool isPlaying;
  final double progress;
  final VoidCallback onTogglePlay;
  final VoidCallback onOpenQueue;
  final VoidCallback? onSkipNext;

  const MiniPlayer({
    super.key,
    required this.song,
    required this.isPlaying,
    required this.progress,
    required this.onTogglePlay,
    required this.onOpenQueue,
    this.onSkipNext,
  });

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0).toDouble();
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.surface, AppColors.surfaceAlt],
            ),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 22,
                offset: const Offset(0, 14),
              ),
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.16),
                blurRadius: 28,
                spreadRadius: 1,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          constraints: const BoxConstraints(minHeight: 60, maxHeight: 92),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _MiniPlayerButton(
                    icon: isPlaying ? Icons.pause : Icons.play_arrow,
                    onPressed: onTogglePlay,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          song.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            letterSpacing: 0.2,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${song.artist} • ${song.album}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            letterSpacing: 0.1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _MiniPlayerButton(
                    icon: Icons.queue_music,
                    onPressed: onOpenQueue,
                  ),
                  const SizedBox(width: 8),
                  _MiniPlayerButton(
                    icon: Icons.skip_next,
                    onPressed: onSkipNext,
                    disabledColor: Colors.white.withValues(alpha: 0.3),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: Stack(
                    children: [
                      Container(color: const Color(0x1AFFFFFF)),
                      ShaderMask(
                        shaderCallback: (rect) => const LinearGradient(
                          colors: [AppColors.accent, AppColors.accent2],
                        ).createShader(rect),
                        blendMode: BlendMode.srcIn,
                        child: LinearProgressIndicator(
                          value: clampedProgress,
                          minHeight: 4,
                          backgroundColor: Colors.transparent,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniPlayerButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? disabledColor;

  const _MiniPlayerButton({
    required this.icon,
    required this.onPressed,
    this.disabledColor,
  });

  @override
  State<_MiniPlayerButton> createState() => _MiniPlayerButtonState();
}

class _MiniPlayerButtonState extends State<_MiniPlayerButton> {
  bool _isHighlighted = false;

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = widget.onPressed == null;
    final double scale = _isHighlighted ? 0.92 : 1.0;
    final List<BoxShadow> shadows = _isHighlighted
        ? [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.26),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ]
        : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 12),
            ),
          ];

    final Color baseColor = isDisabled
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.white.withValues(alpha: 0.12);

    return SizedBox(
      width: 44,
      height: 44,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: shadows,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            splashColor: AppColors.accent.withValues(alpha: 0.18),
            highlightColor: Colors.white.withValues(alpha: 0.08),
            onTap: widget.onPressed,
            onHighlightChanged: (highlighted) {
              if (isDisabled) return;
              if (!mounted) return;
              setState(() => _isHighlighted = highlighted);
            },
            child: AnimatedScale(
              scale: scale,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: baseColor,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: Icon(
                  widget.icon,
                  color: isDisabled
                      ? (widget.disabledColor ?? Colors.white.withValues(alpha: 0.35))
                      : Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

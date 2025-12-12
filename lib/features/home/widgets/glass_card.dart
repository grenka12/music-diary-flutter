import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:music_diary_new/core/theme/app_theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final GestureLongPressStartCallback? onLongPressStart;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.onLongPressStart,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(18);
    final decoration = BoxDecoration(
      borderRadius: borderRadius,
      gradient: const LinearGradient(
        colors: [AppColors.surface, AppColors.surfaceAlt],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.5),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
        BoxShadow(
          color: AppColors.accent.withValues(alpha: 0.1),
          blurRadius: 24,
          spreadRadius: 1,
          offset: const Offset(0, 8),
        ),
      ],
    );

    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onLongPressStart: onLongPressStart,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: borderRadius,
              splashColor: Colors.white.withValues(alpha: 0.08),
              highlightColor: Colors.white.withValues(alpha: 0.04),
              child: Container(
                padding: padding,
                decoration: decoration,
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

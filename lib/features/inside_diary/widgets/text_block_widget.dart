import 'package:flutter/material.dart';

import 'package:music_diary_new/core/theme/app_theme.dart';

class TextBlockWidget extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onTap;
  final bool showPlaceholder;

  const TextBlockWidget({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onTap,
    this.showPlaceholder = false,
  });

  @override
  Widget build(BuildContext context) {
    if (showPlaceholder) {
      return _TextPlaceholderLine(
        onTap: onTap,
        focusNode: focusNode,
      );
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          onChanged: onChanged,
          keyboardType: TextInputType.multiline,
          maxLines: null,
          style: TextStyle(
            color: AppTheme.textPrimary,
            height: 1.5,
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            isCollapsed: true,
            hintText: 'Start writing...',
            hintStyle: TextStyle(color: Colors.white38),
          ),
        ),
      ),
    );
  }
}

class _TextPlaceholderLine extends StatefulWidget {
  final VoidCallback onTap;
  final FocusNode focusNode;

  const _TextPlaceholderLine({required this.onTap, required this.focusNode});

  @override
  State<_TextPlaceholderLine> createState() => _TextPlaceholderLineState();
}

class _TextPlaceholderLineState extends State<_TextPlaceholderLine> {
  bool _hovering = false;

  void _setHovering(bool value) {
    if (_hovering == value) return;
    setState(() {
      _hovering = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color lineColor = Colors.white.withValues(alpha: _hovering ? 0.4 : 0.1);

    return Focus(
      focusNode: widget.focusNode,
      child: MouseRegion(
        onEnter: (_) => _setHovering(true),
        onExit: (_) => _setHovering(false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            widget.onTap();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) {
                return;
              }
              if (!widget.focusNode.hasFocus && widget.focusNode.canRequestFocus) {
                widget.focusNode.requestFocus();
              }
            });
          },
          child: Container(

            padding: const EdgeInsets.symmetric(vertical: 4),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              height: 1,
              width: double.infinity,
              decoration: BoxDecoration(
                color: lineColor,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

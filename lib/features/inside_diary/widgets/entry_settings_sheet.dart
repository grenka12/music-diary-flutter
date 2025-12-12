import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:music_diary_new/core/theme/app_theme.dart';

import '../logic/entry_settings_controller.dart';
import '../logic/diary_provider.dart';

class EntrySettingsSheet extends StatefulWidget {
  const EntrySettingsSheet({
    super.key,
    required this.provider,
    required this.initialTitle,
    this.initialDescription,
    required this.hasCoverImage,
    this.coverImageAsset,
  });

  final DiaryProvider provider;
  final String initialTitle;
  final String? initialDescription;
  final bool hasCoverImage;
  final String? coverImageAsset;

  @override
  State<EntrySettingsSheet> createState() => _EntrySettingsSheetState();
}

class _EntrySettingsSheetState extends State<EntrySettingsSheet> {
  late final EntrySettingsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = EntrySettingsController(
      initialTitle: widget.initialTitle,
      initialDescription: widget.initialDescription,
      hasCoverImage: widget.hasCoverImage,
      coverImageAsset: widget.coverImageAsset,
    )..addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _handleAddPhoto() async {
    await widget.provider.pickAndUploadCoverImage(widget.provider.entry.id);

    if (!mounted) return;
    _controller.setCoverImage(widget.provider.coverImageAsset);
  }

  void _handleSave() {
    final result = _controller.submit();
    if (result != null) Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final coverImageAsset =
        widget.provider.coverImageAsset ?? _controller.coverImageAsset;

    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 20,
          bottom: bottomPadding + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text(
                  'Entry settings',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller.titleController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Title',
                errorText: _controller.titleError,
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.08),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller.descriptionController,
              style: const TextStyle(color: Colors.white),
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Description',
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.08),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: coverImageAsset != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: coverImageAsset.startsWith('http')
                              ? CachedNetworkImage(
                                  imageUrl: coverImageAsset!,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                  errorWidget: (_, __, ___) =>
                                      const Icon(Icons.broken_image),
                                )
                              : Image.asset(
                                  coverImageAsset!,
                                  fit: BoxFit.cover,
                                ),
                        )
                      : const Icon(Icons.photo, color: Colors.white70),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Cover photo',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      SizedBox(height: 4),
                      Text('Tap to add a cover image for this entry.',
                          style: TextStyle(color: Colors.white60, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: _handleAddPhoto,
                  child: const Text('Add photo'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleSave,
                child: const Text('Save changes'),
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

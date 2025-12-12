import 'package:flutter/material.dart';

/// Holds the data returned after editing entry settings.
class EntrySettingsResult {
  const EntrySettingsResult({
    required this.title,
    this.description,
    this.coverImageAsset,
  });

  final String title;
  final String? description;
  final String? coverImageAsset;
}

/// Manages text controllers, validation, and metadata for the settings sheet.
class EntrySettingsController extends ChangeNotifier {
  EntrySettingsController({
    required String initialTitle,
    String? initialDescription,
    required bool hasCoverImage,
    String? coverImageAsset,
  })  : _hasCoverImage = hasCoverImage,
        _coverImageAsset = coverImageAsset,
        titleController = TextEditingController(text: initialTitle),
        descriptionController =
            TextEditingController(text: initialDescription ?? '');

  final bool _hasCoverImage;
  String? _coverImageAsset;

  final TextEditingController titleController;
  final TextEditingController descriptionController;

  String? _titleError;

  /// Error message displayed when validation fails.
  String? get titleError => _titleError;

  /// Indicates whether the entry already has a cover image.
  bool get hasCoverImage => _hasCoverImage;

  /// Asset used for the existing cover image, if available.
  String? get coverImageAsset => _coverImageAsset;

  /// Text used for the placeholder helper message.
  String get coverPlaceholderMessage =>
      'Cover photo support will be available soon.';

  /// Clears any validation errors currently shown in the UI.
  void clearError() {
    if (_titleError != null) {
      _titleError = null;
      notifyListeners();
    }
  }

  /// Validates the form and returns the updated settings result.
  EntrySettingsResult? submit() {
    final title = titleController.text.trim();
    if (title.isEmpty) {
      _titleError = 'Title cannot be empty';
      notifyListeners();
      return null;
    }

    _titleError = null;
    notifyListeners();

    final descriptionText = descriptionController.text.trim();
    return EntrySettingsResult(
      title: title,
      description: descriptionText.isEmpty ? null : descriptionText,
      coverImageAsset: _coverImageAsset,
    );
  }

  /// Updates the cover image value when an upload completes.
  void setCoverImage(String? asset) {
    if (_coverImageAsset != asset) {
      _coverImageAsset = asset;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}

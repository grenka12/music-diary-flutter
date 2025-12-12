import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:music_diary_new/core/data/entry_service.dart';

import 'package:music_diary_new/core/data/json_file_repo.dart';
import 'package:music_diary_new/core/models/user_profile.dart';
import 'package:music_diary_new/features/auth/logic/auth_service.dart';

enum HomeStatus { idle, loading, success, error }

class HomeProvider extends ChangeNotifier {
  HomeProvider({AuthService? authService})
      : _authService = authService ?? AuthService.instance;

  final AuthService _authService;

  HomeStatus _status = HomeStatus.idle;
  List<CachedEntry> _entries = const [];
  UserProfile? _currentUser;
  bool _showAvatarImage = true;
  String? _errorMessage;

  List<CachedEntry> get entries => List.unmodifiable(_entries);
  UserProfile? get currentUser => _currentUser;
  bool get showAvatarImage => _showAvatarImage;
  HomeStatus get status => _status;
  String? get errorMessage => _errorMessage;

  // INIT
  void initialize() {
    _updateAuthState(notify: false);
    _authService.authState.addListener(_handleAuthChanged);
    notifyListeners();
  }

  void _handleAuthChanged() {
    _updateAuthState();
  }

  void _updateAuthState({bool notify = true}) {
    _currentUser = _authService.currentProfile;
    _showAvatarImage = true;
    refreshEntries(notify: false);
    if (notify) notifyListeners();
  }

  // LOAD ENTRIES
  void refreshEntries({bool notify = true}) {
    _status = HomeStatus.loading;
    notifyListeners();

    try {
      final userId = _currentUser?.email;

      if (userId == null) {
        _entries = [];
      } else {
        _entries = JsonFileRepo.entriesForUser(userId);
      }

      _status = HomeStatus.success;
    } catch (e) {
      _entries = [];
      _status = HomeStatus.error;
      _errorMessage = 'Failed to load entries';
    }

    if (notify) notifyListeners();
  }

  // CREATE ENTRY
  Future<CachedEntry?> createEntry() async {
    _status = HomeStatus.loading;
    notifyListeners();

    try {
      final userId = _currentUser?.email ?? 'guest_user';

      final cached = await EntryService.createEntry(userId);

      await FirebaseAnalytics.instance.logEvent(
        name: 'entry_added',
        parameters: {'entry_title': cached.title},
      );

      refreshEntries(notify: false);

      _status = HomeStatus.success;
      notifyListeners();
      return cached;
    } catch (e) {
      _status = HomeStatus.error;
      _errorMessage = 'Failed to create entry';
      notifyListeners();
      return null;
    }
  }

void hideAvatarImage() {
  if (!_showAvatarImage) return;
  _showAvatarImage = false;
  notifyListeners();
}


  // DELETE ENTRY
  Future<void> deleteEntry(CachedEntry entry) async {
    try {
      final userId = _currentUser!.email;
      await EntryService.deleteEntry(userId, entry.id);

      refreshEntries();
    } catch (e) {
      _status = HomeStatus.error;
      _errorMessage = 'Failed to delete entry';
      notifyListeners();
    }
  }

  // RENAME ENTRY
  Future<void> renameEntry(CachedEntry entry, String newTitle) async {
    try {
      final userId = _currentUser!.email;

      final updated = CachedEntry(
        id: entry.id,
        title: newTitle,
        authorId: entry.authorId,
        coverImageAsset: entry.coverImageAsset,
        description: entry.description,
      );

      await EntryService.updateEntryMeta(
        userId: userId,
        cached: updated,
        title: newTitle,
        coverImageAsset: updated.coverImageAsset,
        description: updated.description,
      );

      refreshEntries();
    } catch (e) {
      _status = HomeStatus.error;
      _errorMessage = 'Failed to rename entry';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authService.authState.removeListener(_handleAuthChanged);
    super.dispose();
  }
}

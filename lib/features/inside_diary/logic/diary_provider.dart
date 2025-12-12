import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:music_diary_new/core/data/entry_service.dart';
import 'package:music_diary_new/core/data/storage_repository.dart';

import 'package:music_diary_new/core/models/diary_entry.dart';
import 'package:music_diary_new/core/models/diary_block.dart';
import 'package:music_diary_new/core/models/song.dart';

import 'diary_editor_controller.dart';
import 'entry_settings_controller.dart';
import 'playback_controller.dart';

enum DiaryStatus {
  idle,
  loading,
  success,
  error,
}

class DiaryProvider extends ChangeNotifier {
  DiaryProvider(
  this.entry, {
  DiaryEditorController? editor,
}) : _editor = editor ?? DiaryEditorController(entry: entry) {
  _title = entry.title;
  _description = entry.description;
  _coverImageAsset = entry.coverImageAsset;
}



DiaryEntry entry;

  final DiaryEditorController _editor;

  DiaryStatus _status = DiaryStatus.idle;
  List<DiaryBlock> _blocks = const [];
  String _title = '';
  String? _description;
  String? _coverImageAsset;
  List<Song> _queueSongs = const [];
  String? _errorMessage;

  List<DiaryBlock> get blocks => List.unmodifiable(_blocks);
  String get title => _title;
  String? get description => _description;
  String? get coverImageAsset => _coverImageAsset;
  List<Song> get queueSongs => List.unmodifiable(_queueSongs);
  DiaryStatus get status => _status;
  String? get errorMessage => _errorMessage;

  void loadEntry() {
    _status = DiaryStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _blocks = List<DiaryBlock>.from(entry.blocks);
      _queueSongs = _editor.queueSongs();
      _status = DiaryStatus.success;
    } catch (_) {
      _blocks = const [];
      _queueSongs = const [];
      _status = DiaryStatus.error;
      _errorMessage = 'Failed to load entry';
    }

    notifyListeners();
  }

  Future<bool> addSong({
    required Song song,
    String? activeTextId,
    int? caretOffset,
  }) async {
    if (_editor.containsSong(song.id)) {
      _status = DiaryStatus.error;
      _errorMessage = 'This song is already in the entry.';
      notifyListeners();
      return false;
    }

    _status = DiaryStatus.loading;
    notifyListeners();

    _editor.insertSong(
      song: song,
      activeTextId: activeTextId,
      caretOffset: caretOffset,
    );

    await _persistEntry();
    _refreshEditorState();

    _status = DiaryStatus.success;
    notifyListeners();
    return true;
  }

  Future<String?> removeSong(String blockId) async {
    final result = _editor.removeSong(blockId);

    await _persistEntry();
    _refreshEditorState();

    notifyListeners();
    return result['focusTextId'] as String?;
  }

  Future<void> updateTextBlock(String id, String value) async {
    _editor.updateTextBlock(id, value);

    await _persistEntry();
    _refreshEditorState();

    notifyListeners();
  }

  Future<void> applySettings(EntrySettingsResult result) async {
    _status = DiaryStatus.loading;
    _errorMessage = null;
    notifyListeners();

    _title = result.title;
    _description = result.description;
    _coverImageAsset = result.coverImageAsset ?? _coverImageAsset;

    try {
      await EntryService.updateEntryMetaById(
        userId: entry.authorId,
        entryId: entry.id,
        title: _title,
        coverImageAsset: _coverImageAsset,
        description: _description,
      );

      await _persistEntry();
      _refreshEditorState();

      _status = DiaryStatus.success;
    } catch (e) {
      _status = DiaryStatus.error;
      _errorMessage = 'Failed to update entry settings';
    }

    notifyListeners();
  }

Future<void> pickAndUploadCoverImage(String entryId) async {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  final picker = ImagePicker();
  final pickedImage = await picker.pickImage(source: ImageSource.gallery);

  if (pickedImage == null) return;

  final file = File(pickedImage.path);
  if (!file.existsSync()) return;

  _status = DiaryStatus.loading;
  _errorMessage = null;
  notifyListeners();

  try {
    // upload file to storage
    final url = await StorageRepository.uploadCoverImage(uid, file);

    // update firestore meta
    await EntryService.updateEntryMetaById(
      userId: uid,            // ← FIXED
      entryId: entryId,
      title: _title,
      coverImageAsset: url,
      description: _description,
    );

    _coverImageAsset = url;
    entry.coverImageAsset = url;

    _status = DiaryStatus.success;
  } catch (e) {
    _status = DiaryStatus.error;
    _errorMessage = 'Failed to upload cover image';
  }

  notifyListeners();
}

  Song? currentSong(String? id) => _editor.resolveCurrentSong(id);
  Song? songForBlock(SongBlock block) => _editor.songForBlock(block);

  void skipToNext(PlaybackController playback, String songId) {
    final nextSongId = _editor.nextSongId(songId);
    if (nextSongId != null) {
      playback.start(nextSongId);
    } else {
      playback.stop();
    }
  }

  void _refreshEditorState() {
    _blocks = List<DiaryBlock>.from(_editor.blocks);
    _queueSongs = _editor.queueSongs();
    entry.blocks = _blocks;
  }

  Future<void> _persistEntry() async {
    await EntryService.updateBlocks(entry.id, entry.blocks);
  }
}

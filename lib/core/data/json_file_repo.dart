import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:music_diary_new/core/models/song.dart';

// CACHED ENTRY
class CachedEntry {
  final String id;
  final String title;
  final String authorId;
  final String? coverImageAsset;
  final String? description;

  CachedEntry({
    required this.id,
    required this.title,
    required this.authorId,
    this.coverImageAsset,
    this.description,
  });

  factory CachedEntry.fromJson(Map<String, dynamic> json) {
    return CachedEntry(
      id: json['id'],
      title: json['title'],
      authorId: json['authorId'],
      coverImageAsset: json['coverImageAsset'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'authorId': authorId,
        'coverImageAsset': coverImageAsset,
        'description': description,
      };
}

// JSON LOCAL CACHE REPO 

class JsonFileRepo {
  static late Directory _root;

  static const _songsFile = 'songs.json';
  static const _userEntriesDir = 'user_entries';

  static bool _loaded = false;

  static final List<Song> _songs = [];
  static final Map<String, List<CachedEntry>> _userEntries = {};

  // init
  static Future<void> initialize() async {
    if (_loaded) return;

    final baseDir = await getApplicationDocumentsDirectory();
    _root = Directory('${baseDir.path}/app_data');

    await _root.create(recursive: true);
    await Directory('${_root.path}/$_userEntriesDir').create(recursive: true);

    await _loadSongs();
    await _loadAllUserIndexes();

    _loaded = true;
  }

  // LOAD SONGS
  static Future<void> _loadSongs() async {
    Future<List<dynamic>> readBundledSongs() async {
      final raw = await rootBundle.loadString('assets/data/$_songsFile');
      return jsonDecode(raw) as List<dynamic>;
    }

    final file = File('${_root.path}/$_songsFile');
    if (!await file.exists()) {
      await file.writeAsString(jsonEncode(await readBundledSongs()));
    }

    final raw = await file.readAsString();
    List<dynamic> list;

    try {
      list = jsonDecode(raw) as List<dynamic>;
    } catch (_) {
      list = [];
    }

    if (list.isEmpty) {
      list = await readBundledSongs();
      await file.writeAsString(jsonEncode(list));
    }

    _songs.clear();
    final usedIds = <String>{};

    for (var i = 0; i < list.length; i++) {
      final s = list[i] as Map<String, dynamic>;
      final id = _resolveSongId(s, usedIds, i);
      usedIds.add(id);

      _songs.add(Song(
        id: id,
        title: s['title'] ?? 'Unknown Title',
        artist: s['artist'] ?? 'Unknown Artist',
        album: s['album'] ?? 'Unknown Album',
        imageAsset: s['imageAsset'] ?? 'assets/media/default_user.png',
      ));
    }

    // rewrite normalized file
    await file.writeAsString(
      jsonEncode(
        _songs
            .map((s) => {
                  'id': s.id,
                  'title': s.title,
                  'artist': s.artist,
                  'album': s.album,
                  'imageAsset': s.imageAsset,
                })
            .toList(),
      ),
    );
  }

  static String _resolveSongId(
    Map<String, dynamic> song,
    Set<String> usedIds,
    int index,
  ) {
    String normalize(String value) => value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp('_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');

    final title = song['title'] as String? ?? '';
    final artist = song['artist'] as String? ?? '';
    final provided = (song['id'] as String?)?.trim();

    String base = normalize(
      provided ?? '${normalize(title)}_${normalize(artist)}',
    );
    if (base.isEmpty) base = 'song_$index';

    var candidate = base;
    var suffix = 1;
    while (usedIds.contains(candidate)) {
      candidate = '${base}_$suffix';
      suffix++;
    }

    return candidate;
  }

  // LOAD USER CACHED ENTRIES
  static Future<void> _loadAllUserIndexes() async {
    final dir = Directory('${_root.path}/$_userEntriesDir');

    _userEntries.clear();

    for (final f in dir.listSync().whereType<File>()) {
      final raw = await f.readAsString();
      final json = jsonDecode(raw);

      final userId = json['userId'];
      final list = (json['entries'] as List)
          .map((e) => CachedEntry.fromJson(e))
          .toList();

      _userEntries[userId] = list;
    }
  }

  //GETTERS 
  static List<Song> allSongs() => List.unmodifiable(_songs);

  static List<CachedEntry> entriesForUser(String userId) =>
      List.unmodifiable(_userEntries[userId] ?? []);

  // SAVE USER INDEX
  static Future<void> _saveUserIndex(String userId) async {
    final file = File('${_root.path}/$_userEntriesDir/$userId.json');

    final json = {
      'userId': userId,
      'entries': _userEntries[userId]!
          .map((e) => e.toJson())
          .toList(),
    };

    await file.writeAsString(jsonEncode(json));
  }

  // ADD CACHED ENTRY
  static Future<CachedEntry> addCachedEntry({
    required String userId,
    required String title,
    required String authorId,
    String? id,
    String? coverImageAsset,
    String? description,
  }) async {
    final entryId = id ?? 'entry_${DateTime.now().millisecondsSinceEpoch}';

    final entry = CachedEntry(
      id: entryId,
      title: title,
      authorId: authorId,
      coverImageAsset: coverImageAsset,
      description: description,
    );

    _userEntries.putIfAbsent(userId, () => []);
    _userEntries[userId]!.add(entry);

    await _saveUserIndex(userId);

    return entry;
  }

  //UPDATE CACHED ENTRY
  static Future<void> updateCachedEntry(
      String userId, CachedEntry entry) async {
    if (!_userEntries.containsKey(userId)) return;

    final list = _userEntries[userId]!;
    final index = list.indexWhere((e) => e.id == entry.id);

    if (index == -1) return;

    list[index] = entry;

    await _saveUserIndex(userId);
  }

  // DELETE CACHED ENTRY
  static Future<void> deleteCachedEntry(
      String userId, String entryId) async {
    if (!_userEntries.containsKey(userId)) return;

    _userEntries[userId]!.removeWhere((e) => e.id == entryId);

    await _saveUserIndex(userId);
  }
}

import 'package:music_diary_new/core/data/firebase_repo.dart';
import 'package:music_diary_new/core/data/json_file_repo.dart';
import 'package:music_diary_new/core/models/diary_block.dart';
import 'package:music_diary_new/core/models/diary_entry.dart';

class EntryService {
  // Create a new entry
  static Future<CachedEntry> createEntry(String userId) async {
    // 1) Online 
    final entry = await FirebaseRepo.createEntry(userId);

    // 2) Cached
    final cached = await JsonFileRepo.addCachedEntry(
      userId: userId,
      id: entry.id,
      title: entry.title,
      authorId: entry.authorId,
      coverImageAsset: entry.coverImageAsset,
      description: entry.description,
    );

    return cached;
  }

  // Load full entry
  static Future<DiaryEntry> loadFullEntry(String entryId) async {
    return FirebaseRepo.fetchEntry(entryId);
  }

  // Update metadata
  static Future<void> updateEntryMeta({
    required String userId,
    required CachedEntry cached,
    required String title,
    String? coverImageAsset,
    String? description,
  }) async {
    // 1) Update in Firebase
    await FirebaseRepo.updateEntryMeta(
      entryId: cached.id,
      title: title,
      coverImageAsset: coverImageAsset,
      description: description,
    );

    // 2) Update cached 
    final updated = CachedEntry(
      id: cached.id,
      title: title,
      authorId: cached.authorId,
      coverImageAsset: coverImageAsset,
      description: description,
    );

    await JsonFileRepo.updateCachedEntry(userId, updated);
  }

  static Future<void> updateEntryMetaById({
    required String userId,
    required String entryId,
    required String title,
    String? coverImageAsset,
    String? description,
  }) async {
    // 1) Firebase
    await FirebaseRepo.updateEntryMeta(
      entryId: entryId,
      title: title,
      coverImageAsset: coverImageAsset,
      description: description,
    );

    // 2) cached entry
    final cachedList = JsonFileRepo.entriesForUser(userId);
    CachedEntry? existing;
    for (final e in cachedList) {
      if (e.id == entryId) {
        existing = e;
        break;
      }
    }
    if (existing != null) {
      final updated = CachedEntry(
        id: entryId,
        title: title,
        authorId: existing.authorId,
        coverImageAsset: coverImageAsset,
        description: description,
      );
      await JsonFileRepo.updateCachedEntry(userId, updated);
    }
  }

  // Update blocks
  static Future<void> updateBlocks(
    String entryId,
    List<DiaryBlock> blocks,
  ) async {
    await FirebaseRepo.updateEntryBlocks(
      entryId: entryId,
      blocks: blocks,
    );
  }

  // Delete entry
  static Future<void> deleteEntry(String userId, String entryId) async {
    // 1) Firebase delete
    await FirebaseRepo.deleteEntry(entryId);

    // 2) Local cache delete
    await JsonFileRepo.deleteCachedEntry(userId, entryId);
  }
}

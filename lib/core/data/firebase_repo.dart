import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:music_diary_new/core/models/diary_entry.dart';
import 'package:music_diary_new/core/models/diary_block.dart';

class FirebaseRepo {
  static final _db = FirebaseFirestore.instance;
  static const _collection = "EntryLogic";

  // -----------------------------
  // Load full entry
  // -----------------------------
  static Future<DiaryEntry> fetchEntry(String entryId) async {
    final doc = await _db.collection(_collection).doc(entryId).get();

    if (!doc.exists) {
      throw Exception("Entry not found");
    }

    final raw = doc.data();
    if (raw == null) {
      throw Exception("Entry has no data");
    }

    // Нормалізація на всякий
    final data = Map<String, dynamic>.from(raw);
    data['id'] = data['id'] ?? doc.id;
    final blocks = (data['blocks'] as List<dynamic>? ?? [])
        .map((b) => Map<String, dynamic>.from(b as Map))
        .toList();

    return DiaryEntry.fromJson({
      ...data,
      'blocks': blocks,
    });
  }

  // -----------------------------
  // Create entry
  // -----------------------------
  static Future<DiaryEntry> createEntry(String userId) async {
    final ts = DateTime.now().millisecondsSinceEpoch;
    final id = "entry_$ts";

    final entry = DiaryEntry(
      id: id,
      title: "New Entry",
      authorId: userId,
      coverImageAsset: null,
      description: null,
      blocks: [
        TextBlock(id: "tb_$ts", text: "")
      ],
    );

    await _db.collection(_collection).doc(id).set(entry.toJson());
    return entry;
  }

  // -----------------------------
  // Update metadata
  // -----------------------------
  static Future<void> updateEntryMeta({
    required String entryId,
    required String title,
    required String? coverImageAsset,
    required String? description,
  }) async {
    await _db.collection(_collection).doc(entryId).update({
      "title": title,
      "coverImageAsset": coverImageAsset,
      "description": description,
    });
  }

  // -----------------------------
  // Update blocks
  // -----------------------------
  static Future<void> updateEntryBlocks({
    required String entryId,
    required List<DiaryBlock> blocks,
  }) async {
    await _db.collection(_collection).doc(entryId).update({
      "blocks": blocks.map((b) => b.toJson()).toList(),
    });
  }

  // -----------------------------
  // Delete
  // -----------------------------
  static Future<void> deleteEntry(String entryId) async {
    await _db.collection(_collection).doc(entryId).delete();
  }
}

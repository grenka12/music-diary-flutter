import 'package:music_diary_new/core/models/diary_block.dart';

class DiaryEntry {
  final String id;
  String title;
  String? description;
  String? coverImageAsset;
  String authorId;
  List<DiaryBlock> blocks;

  DiaryEntry({
    required this.id,
    required this.title,
    this.description,
    this.coverImageAsset,
    required this.authorId,
    required this.blocks,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'coverImageAsset': coverImageAsset,
        'authorId': authorId,
        'blocks': blocks.map((b) => b.toJson()).toList(),
      };

  factory DiaryEntry.fromJson(Map<String, dynamic> json) {
    final rawBlocks = json['blocks'];
    final normalizedBlocks = <DiaryBlock>[];

    if (rawBlocks is List) {
      for (final b in rawBlocks) {
        if (b is Map<String, dynamic>) {
          normalizedBlocks.add(DiaryBlock.fromJson(b));
        } else if (b is Map) {
          normalizedBlocks
              .add(DiaryBlock.fromJson(Map<String, dynamic>.from(b)));
        }
      }
    }

    return DiaryEntry(
      id: (json['id'] ?? '').toString(),
      title: json['title'] as String,
      description: json['description'] as String?,
      coverImageAsset: json['coverImageAsset'] as String?,
      authorId: json['authorId'] as String,
      blocks: normalizedBlocks,
    );
  }
}

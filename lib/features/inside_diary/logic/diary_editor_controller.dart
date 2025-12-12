import 'package:music_diary_new/core/models/diary_entry.dart';
import 'package:music_diary_new/core/models/diary_block.dart';
import 'package:music_diary_new/core/models/song.dart';
import 'package:music_diary_new/core/data/json_file_repo.dart';

class DiaryEditorController {
  DiaryEditorController({required this.entry});

  /// Full Firebase entry being edited
  final DiaryEntry entry;

  List<DiaryBlock> get blocks => entry.blocks;

  List<TextBlock> textBlocks() =>
      entry.blocks.whereType<TextBlock>().toList();

  bool containsSong(String id) =>
      entry.blocks.whereType<SongBlock>().any((b) => b.songId == id);

  // --------------------------
  // INSERT SONG BLOCK
  // --------------------------
  SongBlock insertSong({
    required Song song,
    String? activeTextId,
    int? caretOffset,
  }) {
    final newBlock = SongBlock(
      id: 'song_${DateTime.now().millisecondsSinceEpoch}',
      songId: song.id,
    );

    // Ensure first block is text
    if (entry.blocks.isEmpty) {
      entry.blocks.add(
        TextBlock(
          id: 'tb_${DateTime.now().millisecondsSinceEpoch}',
          text: '',
        ),
      );
    }

    // Insert after active block
    if (activeTextId != null) {
      final index = entry.blocks.indexWhere((b) => b.id == activeTextId);
      if (index != -1) {
        entry.blocks.insert(index + 1, newBlock);
        entry.blocks.insert(
          index + 2,
          TextBlock(
            id: 'tb_${DateTime.now().millisecondsSinceEpoch}_after',
            text: '',
          ),
        );
        return newBlock;
      }
    }

    // Default append
    entry.blocks.add(newBlock);
    entry.blocks.add(
      TextBlock(
        id: 'tb_${DateTime.now().millisecondsSinceEpoch}_after',
        text: '',
      ),
    );

    return newBlock;
  }

  // --------------------------
  // REMOVE SONG BLOCK
  // --------------------------
  Map<String, dynamic> removeSong(String blockId) {
    final index = entry.blocks.indexWhere((b) => b.id == blockId);
    if (index == -1) return {};

    entry.blocks.removeAt(index);

    // Merge text blocks if needed
    if (index > 0 &&
        index < entry.blocks.length &&
        entry.blocks[index - 1] is TextBlock &&
        entry.blocks[index] is TextBlock) {
      final left = entry.blocks[index - 1] as TextBlock;
      final right = entry.blocks[index] as TextBlock;
      left.text = '${left.text.trim()}\n${right.text.trim()}'.trim();
      entry.blocks.removeAt(index);
      return {'focusTextId': left.id};
    }

    if (index > 0 && entry.blocks[index - 1] is TextBlock) {
      return {'focusTextId': (entry.blocks[index - 1] as TextBlock).id};
    }

    if (index < entry.blocks.length && entry.blocks[index] is TextBlock) {
      return {'focusTextId': (entry.blocks[index] as TextBlock).id};
    }

    return {};
  }

  // --------------------------
  // UPDATE TEXT BLOCK
  // --------------------------
  void updateTextBlock(String id, String value) {
    final block = entry.blocks
        .whereType<TextBlock>()
        .firstWhere((b) => b.id == id);
    block.text = value;
  }

  // --------------------------
  // SONG RESOLUTION
  // --------------------------
  Song? songForBlock(SongBlock block) {
    return JsonFileRepo.allSongs().firstWhere(
      (s) => s.id == block.songId,
      orElse: () => Song(
        id: 'missing_${block.songId}',
        title: 'Unknown Song',
        artist: 'Unknown Artist',
        album: 'Unknown Album',
        imageAsset: 'assets/images/placeholder.png',
      ),
    );
  }

  List<Song> queueSongs() =>
      entry.blocks.whereType<SongBlock>().map(songForBlock).whereType<Song>().toList();

  String? nextSongId(String songId) {
    final songs = entry.blocks.whereType<SongBlock>().toList();
    final i = songs.indexWhere((s) => s.songId == songId);
    if (i >= 0 && i < songs.length - 1) return songs[i + 1].songId;
    return null;
  }

  Song? resolveCurrentSong(String? songId) {
    if (songId == null) return null;
    return JsonFileRepo.allSongs().firstWhere(
      (s) => s.id == songId,
      orElse: () => Song(
        id: 'missing_$songId',
        title: 'Unknown Song',
        artist: 'Unknown Artist',
        album: 'Unknown Album',
        imageAsset: 'assets/images/placeholder.png',
      ),
    );
  }
}

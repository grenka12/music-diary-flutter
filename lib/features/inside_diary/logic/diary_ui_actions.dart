import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:music_diary_new/core/models/song.dart';

import '../widgets/entry_settings_sheet.dart';
import '../widgets/pick_song_sheet.dart';
import '../widgets/queue_sheet.dart';
import 'diary_provider.dart';
import 'entry_settings_controller.dart';
import 'text_block_coordinator.dart';

class DiaryUIActions {
  const DiaryUIActions();

  Future<void> pickSong(
    BuildContext context,
    TextBlockCoordinator text,
  ) async {
    final provider = context.read<DiaryProvider>();

    final song = await showModalBottomSheet<Song>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const PickSongSheet(),
    );

    if (song == null || !context.mounted) return;

    final activeId = text.activeTextId;
    final caretOffset = activeId != null ? text.caretOffset(activeId) : null;

    final added = await provider.addSong(
      song: song,
      activeTextId: activeId,
      caretOffset: caretOffset,
    );

    if (!added) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This song is already in the entry.')),
      );
    }
  }

  Future<void> openQueue(
    BuildContext context,
    Song currentSong,
    List<Song> queueSongs,
  ) async {
    await showModalBottomSheet<Song>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          QueueSheet(currentSongId: currentSong.id, songs: queueSongs),
    );
  }

Future<void> openSettings(BuildContext context) async {
  final provider = context.read<DiaryProvider>();

  final result = await showModalBottomSheet<EntrySettingsResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => EntrySettingsSheet(
      provider: provider,  // ← ось головне
      initialTitle: provider.title,
      initialDescription: provider.description,
      hasCoverImage: provider.coverImageAsset != null,
      coverImageAsset: provider.coverImageAsset,
    ),
  );

  if (result == null || !context.mounted) return;

  await provider.applySettings(result);
}

}

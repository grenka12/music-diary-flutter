import 'package:flutter/material.dart';
import 'package:music_diary_new/core/data/entry_service.dart';
import 'package:provider/provider.dart';

import 'package:music_diary_new/core/models/diary_block.dart';
import 'package:music_diary_new/core/models/diary_entry.dart';

import 'logic/diary_provider.dart';
import 'logic/diary_ui_actions.dart';
import 'logic/playback_controller.dart';
import 'logic/text_block_coordinator.dart';
import 'widgets/mini_player.dart';
import 'widgets/song_block_widget.dart';
import 'widgets/text_block_widget.dart';

class InsideDiaryPage extends StatelessWidget {
  final String entryId;

  const InsideDiaryPage({super.key, required this.entryId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DiaryEntry>(
      future: EntryService.loadFullEntry(entryId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // loading wait for load //circle progress indicator
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            body: Center(
              child: Text(
                'Failed to load entry',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          );
        }

        final entry = snapshot.data!;

        return ChangeNotifierProvider(
          create: (_) => DiaryProvider(entry)..loadEntry(),
          child: const DiaryView(),
        );
      },
    );
  }
}

class DiaryView extends StatefulWidget {
  const DiaryView({super.key});

  @override
  State<DiaryView> createState() => _DiaryViewState();
}

class _DiaryViewState extends State<DiaryView> {
  late final PlaybackController playback;
  late final TextBlockCoordinator text;

  @override
  void initState() {
    super.initState();
    playback = PlaybackController()..addListener(_handleUpdate);
    text = TextBlockCoordinator(onActiveChanged: (_) => setState(() {}));
  }

  @override
  void dispose() {
    playback.dispose();
    text.dispose();
    super.dispose();
  }

  void _handleUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DiaryProvider>(
      builder: (context, provider, _) {
        final textBlocks = provider.blocks.whereType<TextBlock>().toList();
        text.syncWithBlocks(textBlocks);

        final song = provider.currentSong(playback.activeSongId);
        final queue = provider.queueSongs;

        return Scaffold(
          appBar: AppBar(
            title: Text(provider.title),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => const DiaryUIActions().openSettings(context),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => const DiaryUIActions().pickSong(context, text),
            tooltip: 'Add song',
            child: const Icon(Icons.add),
          ),
          body: SafeArea(
            child: Column(
              children: [
                if (song != null)
                  MiniPlayer(
                    song: song,
                    isPlaying: playback.isPlaying,
                    progress: playback.progress,
                    onTogglePlay: () => playback.toggle(song.id),
                    onOpenQueue: () =>
                        const DiaryUIActions().openQueue(context, song, queue),
                    onSkipNext: () =>
                        provider.skipToNext(playback, song.id),
                  ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 160),
                    children: provider.blocks.map((block) {
                      if (block is TextBlock) {
                        final controller = text.controllerFor(block.id)!;
                        final focusNode = text.focusNodeFor(block.id)!;
                        final showPlaceholder = block.text.trim().isEmpty &&
                            !focusNode.hasFocus &&
                            text.activeTextId != block.id;

                        return TextBlockWidget(
                          key: ValueKey(block.id),
                          controller: controller,
                          focusNode: focusNode,
                          showPlaceholder: showPlaceholder,
                          onChanged: (value) =>
                              provider.updateTextBlock(block.id, value),
                          onTap: () => text.focus(block.id),
                        );
                      }

                      if (block is SongBlock) {
                        final song = provider.songForBlock(block);
                        if (song == null) {
                          debugPrint('Song not found for block ${block.id}');
                          return const SizedBox.shrink();
                        }

                        return SongBlockWidget(
                          key: ValueKey(block.id),
                          song: song,
                          isActive: playback.isActive(song.id),
                          isPlaying: playback.isPlayingSong(song.id),
                          onDelete: () async {
                            final focusId = await provider.removeSong(block.id);
                            if (playback.activeSongId == song.id) {
                              playback.stop();
                            }
                            if (focusId != null) {
                              text.focus(focusId);
                            }
                          },
                          onPlay: () => playback.toggle(song.id),
                        );
                      }

                      return const SizedBox.shrink();
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

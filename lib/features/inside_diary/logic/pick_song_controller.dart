import 'package:flutter/material.dart';

import 'package:music_diary_new/core/data/json_file_repo.dart';
import 'package:music_diary_new/core/models/song.dart';

/// Controls filtering and searching of songs in the PickSongSheet.
class PickSongController extends ChangeNotifier {
  final TextEditingController searchController = TextEditingController();

  late final List<Song> _allSongs = JsonFileRepo.allSongs();

  List<Song> _songs = const [];

  /// Songs that match the current filters.
  List<Song> get songs => _songs;

  /// Initializes listeners and prepares filter options.
  void initialize() {
    searchController.addListener(_handleSearchChanged);
    applyFilters();
  }

  void _handleSearchChanged() {
    applyFilters();
  }

  /// Filters the song list using the active search query.
  void applyFilters() {
    final query = searchController.text.toLowerCase();
    _songs = _allSongs.where((song) {
      final matchesQuery = query.isEmpty ||
          song.title.toLowerCase().contains(query) ||
          song.artist.toLowerCase().contains(query) ||
          song.album.toLowerCase().contains(query);
      return matchesQuery;
    }).toList();
    notifyListeners();
  }

  @override
  void dispose() {
    searchController
      ..removeListener(_handleSearchChanged)
      ..dispose();
    super.dispose();
  }
}

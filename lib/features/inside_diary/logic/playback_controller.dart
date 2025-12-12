import 'dart:async';

import 'package:flutter/material.dart';

/// Controls playback simulation for songs inside a diary entry.
class PlaybackController extends ChangeNotifier {
  PlaybackController({
    this.simulatedDuration = const Duration(minutes: 3, seconds: 30),
  });

  final Duration simulatedDuration;

  String? _activeSongId;
  bool _isPlaying = false;
  double _progress = 0;
  Timer? _timer;

  /// ID of the currently active song, if any.
  String? get activeSongId => _activeSongId;

  /// Indicates whether the active song is currently playing.
  bool get isPlaying => _isPlaying;

  /// Current playback progress represented as 0-1.
  double get progress => _progress;

  /// Returns true when [songId] is the active song.
  bool isActive(String songId) => _activeSongId == songId;

  /// Returns true when [songId] is both active and playing.
  bool isPlayingSong(String songId) => isActive(songId) && _isPlaying;

  /// Toggles playback for the provided song ID.
  void toggle(String songId) {
    if (_activeSongId == songId && _isPlaying) {
      pause();
    } else {
      start(songId);
    }
  }

  /// Starts playback for the provided song ID.
  void start(String songId) {
    _timer?.cancel();
    final isResumingSameSong =
        _activeSongId == songId && !_isPlaying && _progress < 1;

    _activeSongId = songId;
    _isPlaying = true;
    if (!isResumingSameSong) {
      _progress = 0;
    }
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _progress += 1 / simulatedDuration.inSeconds;
      if (_progress >= 1) {
        _progress = 1;
        _isPlaying = false;
        _timer?.cancel();
      }
      notifyListeners();
    });
  }

  /// Pauses the active song without resetting progress.
  void pause() {
    _timer?.cancel();
    _timer = null;
    if (_isPlaying) {
      _isPlaying = false;
      notifyListeners();
    }
  }

  /// Stops playback entirely and clears state.
  void stop() {
    _timer?.cancel();
    _timer = null;
    if (_activeSongId != null || _progress != 0 || _isPlaying) {
      _activeSongId = null;
      _isPlaying = false;
      _progress = 0;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/models/media.dart';
import 'music_library.dart';

enum RepeatMode { off, all, one }

/// Transport state for the whole app. There is no audio backend, so the clock
/// is driven by a ticker — the UI (progress bar, lyric highlight, mini player)
/// behaves exactly as it would against a real decoder.
class PlayerController extends ChangeNotifier {
  PlayerController();

  List<Song> _queue = const [];
  int _index = -1;
  Duration _position = Duration.zero;
  bool _playing = false;
  bool _shuffle = false;
  RepeatMode _repeat = RepeatMode.off;
  double _speed = 1.0;
  int? _sleepMinutes;
  Timer? _ticker;

  List<String> _lyricQueue = const [];
  int _lyricLine = 0;

  Song? get current =>
      _index >= 0 && _index < _queue.length ? _queue[_index] : null;
  List<Song> get queue => List.unmodifiable(_queue);
  Duration get position => _position;
  Duration get duration => current?.duration ?? Duration.zero;
  bool get isPlaying => _playing;
  bool get hasTrack => current != null;
  bool get shuffle => _shuffle;
  RepeatMode get repeat => _repeat;
  double get speed => _speed;
  int? get sleepMinutes => _sleepMinutes;
  List<String> get lyricQueue => _lyricQueue;
  int get lyricLine => _lyricLine;

  double get progress =>
      duration.inMilliseconds == 0 ? 0 : position.inMilliseconds / duration.inMilliseconds;

  /// Index of the lyric line that matches [_position] — one line per equal
  /// slice of the track, which is what the artboard's scrolling block shows.
  void _syncLyricLine() {
    if (_lyricQueue.isEmpty || duration == Duration.zero) return;
    final per = duration.inMilliseconds / _lyricQueue.length;
    _lyricLine = (position.inMilliseconds / per).floor().clamp(0, _lyricQueue.length - 1);
  }

  void playQueue(List<Song> songs, int startIndex, {bool replace = true}) {
    if (replace) _queue = List.of(songs);
    _index = startIndex.clamp(0, _queue.isEmpty ? 0 : _queue.length - 1);
    _position = Duration.zero;
    _lyricQueue = MusicLibrary.lyricsFor(_queue[_index]);
    _syncLyricLine();
    _playing = true;
    _startTicker();
    notifyListeners();
  }

  void toggle() {
    if (!hasTrack) {
      playQueue(MusicLibrary.songs, 0);
      return;
    }
    _playing = !_playing;
    _playing ? _startTicker() : _ticker?.cancel();
    notifyListeners();
  }

  void pause() {
    if (!_playing) return;
    _playing = false;
    _ticker?.cancel();
    notifyListeners();
  }

  void seek(Duration to) {
    if (!hasTrack) return;
    _position = to < Duration.zero ? Duration.zero : (to > duration ? duration : to);
    _syncLyricLine();
    notifyListeners();
  }

  void skip(int seconds) =>
      seek(_position + Duration(seconds: seconds));

  void next() {
    if (_queue.isEmpty) return;
    _index = _shuffle
        ? (_queue.length == 1 ? 0 : (_index + 1) % _queue.length)
        : _index + 1;
    if (_index >= _queue.length) {
      if (_repeat == RepeatMode.off) {
        _index = _queue.length - 1;
        _playing = false;
        _ticker?.cancel();
        notifyListeners();
        return;
      }
      _index = 0;
    }
    _onTrackChanged();
  }

  void previous() {
    if (_queue.isEmpty) return;
    _index = _index - 1;
    if (_index < 0) _index = _repeat == RepeatMode.off ? 0 : _queue.length - 1;
    _onTrackChanged();
  }

  void jumpTo(int index) {
    if (index < 0 || index >= _queue.length) return;
    _index = index;
    _onTrackChanged();
  }

  void addToQueue(Song song) {
    if (_queue.isEmpty) {
      playQueue([song], 0);
      return;
    }
    _queue = [..._queue, song];
    notifyListeners();
  }

  void playNext(Song song) {
    if (_queue.isEmpty) {
      playQueue([song], 0);
      return;
    }
    _queue = [..._queue]..insert((_index + 1).clamp(0, _queue.length), song);
    notifyListeners();
  }

  void removeFromQueue(int index) {
    if (index < 0 || index >= _queue.length) return;
    final list = [..._queue]..removeAt(index);
    _queue = list;
    if (index < _index) _index -= 1;
    notifyListeners();
  }

  void toggleShuffle() {
    _shuffle = !_shuffle;
    notifyListeners();
  }

  void cycleRepeat() {
    _repeat = RepeatMode.values[(_repeat.index + 1) % RepeatMode.values.length];
    notifyListeners();
  }

  void cycleSpeed() {
    const steps = [0.75, 1.0, 1.25, 1.5, 2.0];
    final i = steps.indexOf(_speed);
    _speed = steps[(i + 1) % steps.length];
    notifyListeners();
  }

  void setSleepMinutes(int? minutes) {
    _sleepMinutes = minutes;
    notifyListeners();
  }

  void _onTrackChanged() {
    _position = Duration.zero;
    _lyricQueue = MusicLibrary.lyricsFor(_queue[_index]);
    _lyricLine = 0;
    _playing = true;
    _startTicker();
    notifyListeners();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (!hasTrack) return;
      _position += Duration(milliseconds: (250 * _speed).round());
      if (_position >= duration) {
        if (_repeat == RepeatMode.one) {
          _position = Duration.zero;
        } else {
          next();
          return;
        }
      }
      _syncLyricLine();
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}

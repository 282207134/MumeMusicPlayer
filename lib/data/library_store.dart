import 'package:flutter/foundation.dart';

import 'models/media.dart';
import 'music_library.dart';

enum SongSort { ascending, descending, recent, duration, title }

extension SongSortLabel on SongSort {
  String get label => switch (this) {
    SongSort.ascending => 'Ascending',
    SongSort.descending => 'Descending',
    SongSort.recent => 'Recently Added',
    SongSort.duration => 'Duration',
    SongSort.title => 'Title',
  };
}

/// Everything the user can change about the library itself: what is liked,
/// which playlists exist, sort choices, settings switches.
class LibraryStore extends ChangeNotifier {
  LibraryStore()
    : _favorites = <String>{'s0', 's6', 's8', 's12', 's22'},
      _recentlyPlayed = <String>['s7', 's8', 's0', 's12', 's3', 's19'],
      playlists = MusicLibrary.initialPlaylists(),
      _recentSearches = MusicLibrary.initialRecentSearches.toList();

  final Set<String> _favorites;
  final List<String> _recentlyPlayed;
  final List<String> _recentSearches;

  List<Playlist> playlists;

  SongSort songSort = SongSort.ascending;
  SongSort playlistSort = SongSort.recent;
  bool _darkMode = false;
  bool notifyNewAlbum = true;
  bool notifyConcerts = false;
  bool notifyRecommendations = true;
  bool notifyOffers = false;
  String language = 'English (US)';
  int nextId = 100;

  bool get darkMode => _darkMode;
  set darkMode(bool value) {
    if (_darkMode == value) return;
    _darkMode = value;
    notifyListeners();
  }

  List<Song> get favorites =>
      MusicLibrary.songs.where((s) => _favorites.contains(s.id)).toList();

  bool isFavorite(String songId) => _favorites.contains(songId);

  void toggleFavorite(String songId) {
    _favorites.contains(songId)
        ? _favorites.remove(songId)
        : _favorites.add(songId);
    notifyListeners();
  }

  List<Song> get recentlyPlayed => MusicLibrary.songsByIds(_recentlyPlayed);

  void markPlayed(String songId) {
    _recentlyPlayed.remove(songId);
    _recentlyPlayed.insert(0, songId);
    if (_recentlyPlayed.length > 12) _recentlyPlayed.removeLast();
    notifyListeners();
  }

  List<String> get recentSearches => List.unmodifiable(_recentSearches);

  void pushSearch(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    _recentSearches.removeWhere(
      (q) => q.toLowerCase() == trimmed.toLowerCase(),
    );
    _recentSearches.insert(0, trimmed);
    notifyListeners();
  }

  void removeSearch(String query) {
    _recentSearches.remove(query);
    notifyListeners();
  }

  void clearSearches() {
    _recentSearches.clear();
    notifyListeners();
  }

  Playlist? playlistById(String id) {
    for (final p in playlists) {
      if (p.id == id) return p;
    }
    return null;
  }

  Playlist createPlaylist(String name, {String? cover}) {
    final playlist = Playlist(
      id: 'p${nextId++}',
      name: name.trim().isEmpty ? 'New Playlist' : name.trim(),
      cover: cover ?? MusicLibrary.cover(playlists.length + 3),
      createdOrder: -nextId,
    );
    playlists = [playlist, ...playlists];
    notifyListeners();
    return playlist;
  }

  void renamePlaylist(String id, String name) {
    final index = playlists.indexWhere((p) => p.id == id);
    if (index == -1) return;
    final old = playlists[index];
    playlists[index] = Playlist(
      id: old.id,
      name: name.trim().isEmpty ? old.name : name.trim(),
      cover: old.cover,
      songIds: old.songIds,
      createdOrder: old.createdOrder,
    );
    notifyListeners();
  }

  void deletePlaylist(String id) {
    playlists = playlists.where((p) => p.id != id).toList();
    notifyListeners();
  }

  void addToPlaylist(String playlistId, String songId) {
    final playlist = playlistById(playlistId);
    if (playlist == null || playlist.songIds.contains(songId)) return;
    playlist.songIds.add(songId);
    notifyListeners();
  }

  void removeFromPlaylist(String playlistId, String songId) {
    playlistById(playlistId)?.songIds.remove(songId);
    notifyListeners();
  }

  /// Playlists that already contain [songId] — drives the checkmarks on the
  /// `29_add song to playlist` sheet.
  Set<String> playlistsContaining(String songId) => playlists
      .where((p) => p.songIds.contains(songId))
      .map((p) => p.id)
      .toSet();

  List<Song> sortedSongs(List<Song> source) => switch (songSort) {
    SongSort.ascending => [...source]..sort(_byTitle),
    SongSort.descending => [...source]..sort((a, b) => _byTitle(b, a)),
    SongSort.recent => [...source].reversed.toList(),
    SongSort.duration => [
      ...source,
    ]..sort((a, b) => b.duration.compareTo(a.duration)),
    SongSort.title => [...source]..sort(_byTitle),
  };

  static int _byTitle(Song a, Song b) =>
      a.title.toLowerCase().compareTo(b.title.toLowerCase());

  List<Song> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return MusicLibrary.songs
        .where(
          (s) =>
              s.title.toLowerCase().contains(q) ||
              s.artist.toLowerCase().contains(q) ||
              s.album.toLowerCase().contains(q),
        )
        .toList();
  }
}

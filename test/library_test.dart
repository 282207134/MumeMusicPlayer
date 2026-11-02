import 'package:flutter_test/flutter_test.dart';
import 'package:mume_music_player/data/library_store.dart';
import 'package:mume_music_player/data/music_library.dart';
import 'package:mume_music_player/data/player_controller.dart';

void main() {
  test('library lookups resolve every seeded song to an album and artist', () {
    for (final song in MusicLibrary.songs) {
      expect(MusicLibrary.albumOfSong(song).title, isNotEmpty);
      expect(MusicLibrary.artistOfSong(song).name, isNotEmpty);
    }
  });

  test('favorites toggle and persist across calls', () {
    final store = LibraryStore();
    final before = store.isFavorite('s1');
    store.toggleFavorite('s1');
    expect(store.isFavorite('s1'), !before);
    store.toggleFavorite('s1');
    expect(store.isFavorite('s1'), before);
  });

  test('playlist create, add and delete', () {
    final store = LibraryStore();
    final count = store.playlists.length;
    final playlist = store.createPlaylist('Test');
    expect(store.playlistById(playlist.id), isNotNull);
    store.addToPlaylist(playlist.id, 's0');
    expect(store.playlistById(playlist.id)!.songIds, contains('s0'));
    store.deletePlaylist(playlist.id);
    expect(store.playlists.length, count);
  });

  test('search matches title, artist and album', () {
    final store = LibraryStore();
    expect(store.search('starboy'), isNotEmpty);
    expect(store.search('weeknd'), isNotEmpty);
    expect(store.search('zzzzz-not-a-song'), isEmpty);
  });

  test('player advances the queue and respects repeat mode', () {
    final player = PlayerController();
    player.playQueue(MusicLibrary.songs.take(3).toList(), 0);
    expect(player.current!.id, MusicLibrary.songs[0].id);
    player.next();
    expect(player.current!.id, MusicLibrary.songs[1].id);
    player.cycleRepeat();
    expect(player.repeat, RepeatMode.all);
  });

  test('speed cycles through the supported range', () {
    final player = PlayerController();
    final seen = <double>{};
    for (var i = 0; i < 8; i++) {
      player.cycleSpeed();
      seen.add(player.speed);
    }
    expect(seen, containsAll(<double>[1.0, 1.25, 2.0]));
  });
}

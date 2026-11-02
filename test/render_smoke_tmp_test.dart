import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mume_music_player/app/router.dart';
import 'package:mume_music_player/app/theme/app_theme.dart';
import 'package:mume_music_player/app/widgets/app_shell.dart';
import 'package:mume_music_player/data/library_store.dart';
import 'package:mume_music_player/data/player_controller.dart';
import 'package:mume_music_player/features/favorites/favorites_screen.dart';
import 'package:mume_music_player/features/playlist/add_to_playlist_screen.dart';
import 'package:mume_music_player/features/playlist/new_playlist_screen.dart';
import 'package:mume_music_player/features/playlist/playlist_details_screen.dart';
import 'package:mume_music_player/features/playlist/playlists_screen.dart';
import 'package:provider/provider.dart';

Future<void> _usePhone(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(428, 926));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

Widget _host(Widget child, LibraryStore library) => MultiProvider(
      providers: [
        ChangeNotifierProvider<LibraryStore>.value(value: library),
        ChangeNotifierProvider(create: (_) => PlayerController()),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        onGenerateRoute: AppRouter.onGenerateRoute,
        home: child,
      ),
    );

Widget _probe(LibraryStore library) => _host(
      const Scaffold(key: Key('probe'), body: SizedBox.shrink()),
      library,
    );

void main() {
  testWidgets('favorites tab', (tester) async {
    await _usePhone(tester);
    final library = LibraryStore();
    await tester.pumpWidget(_host(
        MumeScaffold(
            selectedTab: ShellTab.favorites, body: const FavoritesScreen()),
        library));
    await tester.pumpAndSettle();
    expect(find.text('Favorites'), findsWidgets);
    expect(find.text('${library.favorites.length} favorites'), findsOneWidget);
    expect(find.byIcon(Icons.more_vert_rounded), findsWidgets);

    await tester.tap(find.text(library.songSort.label).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Duration'));
    await tester.pumpAndSettle();
    expect(library.songSort, SongSort.duration);

    await tester.tap(find.byIcon(Icons.more_vert_rounded).first);
    await tester.pumpAndSettle();
    expect(find.text('Add to Playing Queue'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('favorites empty state', (tester) async {
    await _usePhone(tester);
    final library = LibraryStore();
    for (final song in library.favorites) {
      library.toggleFavorite(song.id);
    }
    await tester.pumpWidget(_host(const FavoritesScreen(), library));
    await tester.pumpAndSettle();
    expect(find.text('No favorites yet'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('playlists tab + option sheet', (tester) async {
    await _usePhone(tester);
    final library = LibraryStore();
    await tester.pumpWidget(_host(const PlaylistsScreen(), library));
    await tester.pumpAndSettle();
    expect(find.text('Add New Playlist'), findsOneWidget);
    expect(find.text('My Favorite Songs'), findsOneWidget);

    await tester.tap(find.text('Recently Added'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Most Songs'));
    await tester.pumpAndSettle();
    expect(library.playlistSort, SongSort.duration);

    await tester.tap(find.byIcon(Icons.more_vert_rounded).first);
    await tester.pumpAndSettle();
    expect(find.text('Play Next'), findsOneWidget);
    expect(find.text('Add to Playing Queue'), findsOneWidget);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Delete playlist?'), findsOneWidget);
    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();
    expect(library.playlists, hasLength(5));
    expect(find.text('My Favorite Songs'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('playlists tab -> share + edit', (tester) async {
    await _usePhone(tester);
    final library = LibraryStore();
    await tester.pumpWidget(_host(const PlaylistsScreen(), library));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.more_vert_rounded).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Share'));
    await tester.pumpAndSettle();
    expect(find.textContaining('is not part of this demo'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.more_vert_rounded).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    expect(find.text('Edit Playlist'), findsOneWidget);
    expect(find.text('My Favorite Songs'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('new playlist create lands on its board', (tester) async {
    await _usePhone(tester);
    final library = LibraryStore();
    await tester.pumpWidget(_host(const NewPlaylistScreen(), library));
    await tester.pumpAndSettle();
    expect(find.text('Create Playlist'), findsOneWidget);
    await tester.tap(find.text('Create Playlist'));
    await tester.pump();
    expect(library.playlists, hasLength(6)); // still blocked, no name typed

    await tester.enterText(find.byType(TextField), 'Road Trip');
    await tester.pump();
    await tester.tap(find.text('Create Playlist'));
    await tester.pumpAndSettle();
    expect(library.playlists.first.name, 'Road Trip');
    expect(find.text('Road Trip'), findsWidgets);
    expect(find.textContaining('0 songs'), findsOneWidget); // details board
    expect(tester.takeException(), isNull);
  });

  testWidgets('new playlist rename', (tester) async {
    await _usePhone(tester);
    final library = LibraryStore();
    await tester.pumpWidget(
        _host(const NewPlaylistScreen(playlistId: 'p1'), library));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '90s Rewind');
    await tester.pump();
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();
    expect(library.playlistById('p1')!.name, '90s Rewind');
    expect(tester.takeException(), isNull);
  });

  testWidgets('playlist details, add songs sheet', (tester) async {
    await _usePhone(tester);
    final library = LibraryStore();
    final created = library.createPlaylist('Road Trip');
    await tester.pumpWidget(_host(
        PlaylistDetailsScreen(playlistId: created.id, key: UniqueKey()),
        library));
    await tester.pumpAndSettle();
    expect(find.text('Road Trip'), findsOneWidget);
    expect(find.textContaining('songs  |  '), findsOneWidget);

    await tester.tap(find.text('Add Songs'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Starboy - The Weeknd').last);
    await tester.pumpAndSettle();
    expect(created.songIds, contains('s0'));
    expect(find.text('Starboy'), findsWidgets);

    await tester.tap(find.byIcon(Icons.more_vert_rounded).last);
    await tester.pumpAndSettle();
    expect(find.text('Go to Album'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('playlist details of an empty board', (tester) async {
    await _usePhone(tester);
    final library = LibraryStore()..createPlaylist('Empty One');
    await tester.pumpWidget(_host(
        PlaylistDetailsScreen(
            playlistId: library.playlists.first.id, key: UniqueKey()),
        library));
    await tester.pumpAndSettle();
    expect(find.text('Nothing in here yet'), findsOneWidget);
    expect(find.text('Shuffle'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('playlist details unknown id', (tester) async {
    await _usePhone(tester);
    await tester.pumpWidget(_host(
        const PlaylistDetailsScreen(playlistId: 'zz'), LibraryStore()));
    await tester.pumpAndSettle();
    expect(find.text('Playlist unavailable'), findsOneWidget);
    await tester.tap(find.text('Go to Playlists'));
    await tester.pumpAndSettle();
    expect(find.text('Add New Playlist'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('add to playlist toggles both ways', (tester) async {
    await _usePhone(tester);
    final library = LibraryStore();
    final created = library.createPlaylist('Road Trip');
    await tester.pumpWidget(_probe(library));
    Future<void> open() async {
      Navigator.of(tester.element(find.byKey(const Key('probe'))))
          .pushNamed(Routes.addToPlaylist, arguments: const MediaArgs('s2'));
      await tester.pumpAndSettle();
    }

    await open();
    expect(find.text('New Playlist'), findsOneWidget);
    expect(find.byTooltip('Remove from this playlist'), findsOneWidget);
    expect(find.byTooltip('Add to this playlist'), findsNWidgets(6));

    await tester.tap(find.byTooltip('Add to this playlist').first);
    await tester.pumpAndSettle();
    expect(created.songIds, contains('s2')); // added, then popped the picker
    expect(find.byKey(const Key('probe')), findsOneWidget);

    await open();
    expect(find.byTooltip('Remove from this playlist'), findsNWidgets(2));
    await tester.tap(find.byTooltip('Remove from this playlist').first);
    await tester.pumpAndSettle();
    expect(created.songIds, isNot(contains('s2')));
    expect(find.byTooltip('Remove from this playlist'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('seeded playlists reject song writes (data layer)',
      (tester) async {
    final library = LibraryStore();
    expect(
      () => library.addToPlaylist('p0', 's0'),
      throwsUnsupportedError,
    );
  });

  testWidgets('every board renders in dark mode', (tester) async {
    await _usePhone(tester);
    final library = LibraryStore();
    for (final screen in <Widget>[
      const FavoritesScreen(),
      const PlaylistsScreen(),
      const NewPlaylistScreen(),
      const PlaylistDetailsScreen(playlistId: 'p0'),
      const AddToPlaylistScreen(songId: 's0'),
    ]) {
      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider<LibraryStore>.value(value: library),
          ChangeNotifierProvider(create: (_) => PlayerController()),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: ThemeMode.dark,
          onGenerateRoute: AppRouter.onGenerateRoute,
          home: screen,
        ),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });
}

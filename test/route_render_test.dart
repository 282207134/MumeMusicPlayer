import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mume_music_player/app/router.dart';
import 'package:mume_music_player/app/theme/app_theme.dart';
import 'package:mume_music_player/data/library_store.dart';
import 'package:mume_music_player/data/music_library.dart';
import 'package:mume_music_player/data/player_controller.dart';
import 'package:provider/provider.dart';

/// Every route the app can navigate to, with the arguments it expects.
const _routes = <(String, Object?, String)>[
  (Routes.splash, null, 'splash'),
  (Routes.walkthrough, null, 'walkthrough'),
  (Routes.home, null, 'home'),
  (Routes.favorites, null, 'favorites'),
  (Routes.playlists, null, 'playlists'),
  (Routes.settings, null, 'settings'),
  (Routes.search, null, 'search'),
  (Routes.player, null, 'player'),
  (Routes.lyrics, null, 'lyrics'),
  (Routes.recentlyPlayed, null, 'recently played'),
  (Routes.artist, MediaArgs('a0'), 'artist details'),
  (Routes.album, MediaArgs('al0'), 'album details'),
  (Routes.folder, MediaArgs('f0'), 'folder details'),
  (Routes.playlist, MediaArgs('p0'), 'playlist details'),
  (Routes.newPlaylist, null, 'new playlist'),
  (Routes.addToPlaylist, MediaArgs('s0'), 'add to playlist'),
  (Routes.addSongs, MediaArgs('p0'), 'add songs'),
  (Routes.notification, null, 'notification'),
  (Routes.language, null, 'language'),
  (Routes.shareApp, null, 'share app'),
  (Routes.faq, null, 'faq'),
  (Routes.premium, null, 'premium'),
  (Routes.paymentMethod, null, 'payment method'),
  (Routes.cardForm, null, 'card form'),
  (Routes.reviewSummary, null, 'review summary'),
  (Routes.subscriptionDone, null, 'subscription success'),
];

Widget _harness(String route, Object? args, bool dark) {
  final library = LibraryStore()..darkMode = dark;
  final player = PlayerController();
  if (route == Routes.player || route == Routes.lyrics) {
    player
      ..playQueue(MusicLibrary.songs, 0)
      ..pause();
  }
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => library),
      ChangeNotifierProvider(create: (_) => player),
    ],
    child: MaterialApp(
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      initialRoute: route,
      onGenerateRoute: AppRouter.onGenerateRoute,
    ),
  );
}

void main() {
  for (final dark in [false, true]) {
    final mode = dark ? 'dark' : 'light';
    for (final (route, args, label) in _routes) {
      for (final (w, h) in const [(428.0, 926.0), (375.0, 812.0)]) {
        testWidgets('$label renders at ${w.toInt()}x${h.toInt()} $mode', (
          tester,
        ) async {
          tester.view.physicalSize = Size(w, h);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.reset);

          await tester.pumpWidget(_harness(route, args, dark));
          await tester.pump(const Duration(milliseconds: 400));
          // The splash schedules its own hand-off timer; let it fire.
          if (route == Routes.splash) {
            await tester.pump(const Duration(seconds: 2, milliseconds: 100));
          }
          expect(tester.takeException(), isNull, reason: '$route ($mode)');

          // Unmount so the providers dispose the playback ticker.
          await tester.pumpWidget(const SizedBox.shrink());
        });
      }
    }
  }
}

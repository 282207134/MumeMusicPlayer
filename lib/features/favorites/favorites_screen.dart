import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimens.dart';
import '../../app/theme/app_theme.dart';
import '../../app/widgets/app_logo.dart';
import '../../app/widgets/buttons.dart';
import '../../app/widgets/song_option_sheet.dart';
import '../../app/widgets/sort_menu.dart';
import '../../app/widgets/tiles.dart';
import '../../data/library_store.dart';
import '../../data/models/media.dart';
import '../../data/player_controller.dart';

/// `23_favorites` — the liked-song board. It doubles as the Favorites tab, so
/// the outer `RootShell` owns the mini player and the bottom bar; this page
/// only paints its own header and list.
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  static const _choices = <SortChoice<SongSort>>[
    SortChoice(SongSort.ascending, 'Ascending'),
    SortChoice(SongSort.descending, 'Descending'),
    SortChoice(SongSort.recent, 'Date Added'),
    SortChoice(SongSort.duration, 'Duration'),
    SortChoice(SongSort.title, 'Title'),
  ];

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryStore>();
    final player = context.watch<PlayerController>();
    final songs = library.sortedSongs(library.favorites);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          // Bottom room for the mini player + nav bar drawn by the root shell.
          padding: const EdgeInsets.fromLTRB(
              Insets.page, Insets.gapLg, Insets.page, 152),
          children: [
            AppWordmark(
              title: 'Favorites',
              onSearch: () => Navigator.of(context).pushNamed(Routes.search),
            ),
            const SizedBox(height: Insets.gapLg),
            Row(
              children: [
                Expanded(
                  child: PrimaryPillButton(
                    label: 'Shuffle',
                    icon: Icons.shuffle_rounded,
                    onPressed: songs.isEmpty
                        ? null
                        : () => _play(context, songs, 0, shuffle: true),
                  ),
                ),
                const SizedBox(width: Insets.gapMd),
                Expanded(
                  child: SoftPillButton(
                    label: 'Play',
                    icon: Icons.play_circle_fill_rounded,
                    color: AppColors.primary,
                    onPressed: songs.isEmpty
                        ? null
                        : () => _play(context, songs, 0),
                  ),
                ),
              ],
            ),
            CountSortBar(
              count: '${songs.length} favorites',
              sortLabel: library.songSort.label,
              onSort: () async {
                final picked = await showSortMenu<SongSort>(
                  context,
                  choices: _choices,
                  selected: library.songSort,
                );
                if (picked != null) library.songSort = picked;
              },
            ),
            if (songs.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: Insets.gapXl),
                child: EmptyState(
                  title: 'No favorites yet',
                  message:
                      'Tap the heart on any track and it will be waiting for you here.',
                  icon: Icons.favorite_outline_rounded,
                ),
              )
            else ...[
              Divider(color: context.separatorColor),
              for (var i = 0; i < songs.length; i++) ...[
                if (i > 0) Divider(color: context.separatorColor),
                SongTile(
                  song: songs[i],
                  active:
                      player.current?.id == songs[i].id && player.isPlaying,
                  onTap: () => _play(context, songs, i),
                  onPlay: () => player.current?.id == songs[i].id
                      ? player.toggle()
                      : _play(context, songs, i),
                  onMenu: () => showSongOptions(context, songs[i]),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  static void _play(
    BuildContext context,
    List<Song> songs,
    int index, {
    bool shuffle = false,
  }) {
    final player = context.read<PlayerController>();
    if (shuffle && !player.shuffle) player.toggleShuffle();
    player.playQueue(songs, index);
    context.read<LibraryStore>().markPlayed(songs[index].id);
    Navigator.of(context).pushNamed(Routes.player);
  }
}

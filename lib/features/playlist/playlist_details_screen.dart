import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimens.dart';
import '../../app/theme/app_theme.dart';
import '../../app/theme/app_typography.dart';
import '../../app/widgets/app_logo.dart';
import '../../app/widgets/buttons.dart';
import '../../app/widgets/page.dart';
import '../../app/widgets/sheets.dart';
import '../../app/widgets/song_option_sheet.dart';
import '../../app/widgets/tiles.dart';
import '../../data/library_store.dart';
import '../../data/models/media.dart';
import '../../data/music_library.dart';
import '../../data/player_controller.dart';

/// `27_playlist details` — artwork, the two transport pills and the track list.
class PlaylistDetailsScreen extends StatelessWidget {
  const PlaylistDetailsScreen({super.key, required this.playlistId});

  final String playlistId;

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryStore>();
    final player = context.watch<PlayerController>();
    final playlist = library.playlistById(playlistId);
    final songs = playlist == null
        ? const <Song>[]
        : MusicLibrary.songsByIds(playlist.songIds);
    final total =
        Duration(seconds: songs.fold<int>(0, (t, s) => t + s.duration.inSeconds));

    return Scaffold(
      appBar: PageTopBar(
        actions: [
          GhostIconButton(
            icon: Icons.search_rounded,
            tooltip: 'Search',
            onPressed: () => Navigator.of(context).pushNamed(Routes.search),
          ),
          const SizedBox(width: Insets.gapSm),
          OutlinedIconButton(
            icon: Icons.circle_outlined,
            tooltip: 'Toggle theme',
            size: 40,
            onPressed: () => library.darkMode = !library.darkMode,
          ),
        ],
      ),
      body: playlist == null
          ? EmptyState(
              title: 'Playlist unavailable',
              message:
                  'This playlist has been deleted. Pick another one from the Playlists board.',
              icon: Icons.playlist_remove_rounded,
              action: SoftPillButton(
                label: 'Go to Playlists',
                icon: Icons.queue_music_rounded,
                color: context.inkPrimary,
                onPressed: () => Navigator.of(context)
                    .pushReplacementNamed(Routes.playlists),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                  Insets.page, 0, Insets.page, Insets.gap2xl),
              children: [
                Center(
                  child: CoverArt(
                    asset: playlist.cover,
                    size: 232,
                    radius: Insets.radiusXl,
                  ),
                ),
                const SizedBox(height: Insets.gapXl),
                Text(
                  playlist.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppTypography.heading(AppTypography.h3,
                      color: context.inkPrimary),
                ),
                const SizedBox(height: Insets.gapSm),
                Text(
                  '${songs.length} songs  |  ${formatClock(total)} mins',
                  textAlign: TextAlign.center,
                  style: AppTypography.body(AppTypography.bodyLarge,
                      color: context.inkMuted),
                ),
                const SizedBox(height: Insets.gapXl),
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
                const SizedBox(height: Insets.gapXl),
                Divider(color: context.separatorColor),
                SectionHeader(
                  title: 'Songs',
                  actionLabel: 'Add Songs',
                  onAction: () => _addSongs(context, playlist),
                  padding: const EdgeInsets.only(
                      top: Insets.gapLg, bottom: Insets.gapMd),
                ),
                if (songs.isEmpty)
                  const EmptyState(
                    title: 'Nothing in here yet',
                    message:
                        'Add a few tracks and this board becomes your mixtape.',
                    icon: Icons.playlist_add_rounded,
                  )
                else
                  for (var i = 0; i < songs.length; i++) ...[
                    if (i > 0) Divider(color: context.separatorColor),
                    SongTile(
                      song: songs[i],
                      active: player.current?.id == songs[i].id &&
                          player.isPlaying,
                      onTap: () => _play(context, songs, i),
                      onPlay: () => player.current?.id == songs[i].id
                          ? player.toggle()
                          : _play(context, songs, i),
                      onMenu: () => showSongOptions(context, songs[i]),
                    ),
                  ],
              ],
            ),
    );
  }

  void _play(
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

  /// The `+` on `27_playlist details`: a picker of everything not in the board
  /// yet, since the rest of the app files songs *into* playlists instead.
  void _addSongs(BuildContext context, Playlist playlist) {
    final library = context.read<LibraryStore>();
    final candidates = MusicLibrary.songs
        .where((s) => !playlist.songIds.contains(s.id))
        .toList();

    showMumeSheet(
      context,
      builder: (ctx) => MumeSheet(
        title: 'Add Songs',
        children: [
          if (candidates.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Insets.gapXl),
              child: Text(
                'Every song in the library is already in ${playlist.name}.',
                style: AppTypography.body(AppTypography.bodyLarge,
                    color: ctx.inkMuted),
              ),
            )
          else
            for (var i = 0; i < candidates.length; i++) ...[
              if (i > 0) Divider(color: ctx.separatorColor),
              InkWell(
                onTap: () {
                  Navigator.of(ctx).pop();
                  final song = candidates[i];
                  library.addToPlaylist(playlist.id, song.id);
                  showSnack(context, '${song.title} added to ${playlist.name}');
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: Insets.gapMd),
                  child: Row(
                    children: [
                      CoverArt(
                          asset: candidates[i].cover,
                          size: Insets.coverTile,
                          radius: Insets.radiusMd),
                      const SizedBox(width: Insets.gapLg),
                      Expanded(
                        child: Text(
                          '${candidates[i].title} - ${candidates[i].artist}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.body(
                            AppTypography.bodyLarge,
                            weight: FontWeight.w600,
                            color: ctx.inkPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: Insets.gapMd),
                      const Icon(Icons.add_rounded,
                          color: AppColors.primary, size: 24),
                    ],
                  ),
                ),
              ),
            ],
        ],
      ),
    );
  }
}

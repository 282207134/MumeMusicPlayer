import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimens.dart';
import '../../app/theme/app_theme.dart';
import '../../app/theme/app_typography.dart';
import '../../app/widgets/app_logo.dart';
import '../../app/widgets/buttons.dart';
import '../../app/widgets/detail_sections.dart';
import '../../app/widgets/page.dart';
import '../../app/widgets/song_option_sheet.dart';
import '../../app/widgets/tiles.dart';
import '../../data/library_store.dart';
import '../../data/models/media.dart';
import '../../data/music_library.dart';
import '../../data/player_controller.dart';
import 'playlists_screen.dart';

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
    final total = Duration(
      seconds: songs.fold<int>(0, (t, s) => t + s.duration.inSeconds),
    );

    return Scaffold(
      appBar: PageTopBar(
        actions: [
          GhostIconButton(
            icon: Icons.search_rounded,
            tooltip: 'Search',
            onPressed: () => Navigator.of(context).pushNamed(Routes.search),
          ),
          const SizedBox(width: Insets.gapSm),
          Builder(
            builder: (anchor) => OutlinedIconButton(
              icon: Icons.circle_outlined,
              tooltip: 'Playlist options',
              size: 40,
              onPressed: () => _showOptions(anchor),
            ),
          ),
        ],
      ),
      body: playlist == null
          ? EmptyState(
              title: 'Playlist unavailable',
              message: 'This playlist has been deleted. Pick another one from the Playlists board.',
              icon: Icons.playlist_remove_rounded,
              action: SoftPillButton(
                label: 'Go to Playlists',
                icon: Icons.queue_music_rounded,
                color: context.inkPrimary,
                onPressed: () =>
                    Navigator.of(context)
                        .pushReplacementNamed(Routes.playlists),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                Insets.page,
                0,
                Insets.page,
                Insets.gap2xl,
              ),
              children: [
                Center(
                  child: CoverArt(
                    asset: playlist.cover,
                    size: Insets.coverDetail,
                    radius: Insets.radiusDetailCover,
                  ),
                ),
                const SizedBox(height: Insets.gapXl),
                Text(
                  playlist.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppTypography.heading(
                    AppTypography.h3,
                    color: context.inkPrimary,
                  ),
                ),
                const SizedBox(height: Insets.gapSm),
                Text(
                  '${songs.length} Songs  |  ${formatTotal(total)} mins',
                  textAlign: TextAlign.center,
                  style: AppTypography.body(
                    AppTypography.bodyLarge,
                    color: context.inkMuted,
                  ),
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
                            : () => playSongs(context, songs, 0, shuffle: true),
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
                            : () => playSongs(context, songs, 0),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Insets.gapXl),
                Divider(color: context.separatorColor),
                Padding(
                  padding: const EdgeInsets.only(
                    top: Insets.gapLg,
                    bottom: Insets.gapMd,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.swap_vert_rounded,
                        color: AppColors.primary,
                        size: 22,
                      ),
                      const SizedBox(width: Insets.gapSm),
                      Expanded(
                        child: Text(
                          'Date Added',
                          style: AppTypography.body(
                            AppTypography.bodyXLarge,
                            weight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      InkWell(
                        borderRadius: BorderRadius.circular(Insets.radiusMd),
                        onTap: () => _addSongs(context, playlist),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(
                              Insets.radiusMd,
                            ),
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: AppColors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
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
                    SongTile(
                      song: songs[i],
                      active:
                          player.current?.id == songs[i].id && player.isPlaying,
                      onTap: () => playSongs(context, songs, i),
                      onPlay: () => player.current?.id == songs[i].id
                          ? player.toggle()
                          : playSongs(context, songs, i),
                      onMenu: () => showSongOptions(context, songs[i]),
                    ),
                  ],
              ],
            ),
    );
  }

  /// `28_playlist option menu` — anchored under the header's circle button.
  Future<void> _showOptions(BuildContext context) async {
    final library = context.read<LibraryStore>();
    final playlist = library.playlistById(playlistId);
    final box = context.findRenderObject() as RenderBox?;
    if (playlist == null || box == null) return;
    final origin = box.localToGlobal(Offset.zero);
    final action = await showMenu<String>(
      context: context,
      color: context.cardBackground,
      elevation: 12,
      constraints: const BoxConstraints.tightFor(width: 200),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Insets.radiusLg),
      ),
      position: RelativeRect.fromLTRB(
        origin.dx + box.size.width - 200,
        origin.dy + box.size.height + Insets.gapMd,
        origin.dx + box.size.width,
        origin.dy,
      ),
      items: [
        _option(context, 'edit', Icons.edit_outlined, 'Edit Playlist Info'),
        const PopupMenuDivider(height: 1),
        _option(
          context,
          'delete',
          Icons.delete_outline_rounded,
          'Delete Playlist',
        ),
      ],
    );
    if (!context.mounted) return;
    switch (action) {
      case 'edit':
        Navigator.of(context)
            .pushNamed(Routes.newPlaylist, arguments: MediaArgs(playlist.id));
      case 'delete':
        if (await confirmDeletePlaylist(context, library, playlist) &&
            context.mounted) {
          Navigator.of(context).pop();
        }
    }
  }

  PopupMenuItem<String> _option(
    BuildContext context,
    String value,
    IconData icon,
    String label,
  ) => PopupMenuItem<String>(
    value: value,
    padding: const EdgeInsets.symmetric(horizontal: Insets.gapLg),
    child: Row(
      children: [
        Icon(icon, size: 20, color: context.inkPrimary),
        const SizedBox(width: Insets.gapMd),
        Text(
          label,
          style: AppTypography.body(
            AppTypography.bodyLarge,
            weight: FontWeight.w700,
            color: context.inkPrimary,
          ),
        ),
      ],
    ),
  );

  /// `29_add song to playlist` — the board's own picker, opened from `+`.
  void _addSongs(BuildContext context, Playlist playlist) =>
      Navigator.of(context)
          .pushNamed(Routes.addSongs, arguments: MediaArgs(playlist.id));
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimens.dart';
import '../../app/theme/app_theme.dart';
import '../../app/theme/app_typography.dart';
import '../../app/widgets/buttons.dart';
import '../../app/widgets/page.dart';
import '../../app/widgets/sheets.dart';
import '../../app/widgets/song_option_sheet.dart';
import '../../app/widgets/sort_menu.dart';
import '../../app/widgets/tiles.dart';
import '../../data/library_store.dart';
import '../../data/models/media.dart';
import '../../data/music_library.dart';
import '../../data/player_controller.dart';

/// `25_playlists` — every playlist, with the create entry point pinned on top.
class PlaylistsScreen extends StatelessWidget {
  const PlaylistsScreen({super.key});

  static const _choices = <SortChoice<SongSort>>[
    SortChoice(SongSort.recent, 'Recently Added'),
    SortChoice(SongSort.title, 'Name'),
    SortChoice(SongSort.duration, 'Most Songs'),
    SortChoice(SongSort.ascending, 'Fewest Songs'),
  ];

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryStore>();
    final playlists = _sorted(library.playlists, library.playlistSort);

    return Scaffold(
      appBar: PageTopBar(
        title: 'Playlists',
        actions: [
          GhostIconButton(
            icon: Icons.search_rounded,
            tooltip: 'Search',
            onPressed: () => Navigator.of(context).pushNamed(Routes.search),
          ),
        ],
      ),
      body: ListView(
        // Bottom room for the mini player + nav bar drawn by the root shell.
        padding: const EdgeInsets.fromLTRB(Insets.page, 0, Insets.page, 152),
        children: [
          CountSortBar(
            count: MusicLibrary.playlistCountLabel,
            sortLabel: library.playlistSort.label,
            onSort: (anchor) async {
              final picked = await showSortMenu<SongSort>(
                anchor,
                choices: _choices,
                selected: library.playlistSort,
              );
              if (picked != null) library.playlistSort = picked;
            },
          ),
          Divider(color: context.separatorColor),
          InkWell(
            onTap: () => Navigator.of(context).pushNamed(Routes.newPlaylist),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: Insets.gapMd),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: AppColors.gradientOrange,
                      ),
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: AppColors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: Insets.gapLg),
                  Expanded(
                    child: Text(
                      'Add New Playlist',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.body(
                        AppTypography.bodyXLarge,
                        weight: FontWeight.w700,
                        color: context.inkPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          for (final playlist in playlists) ...[
            PlaylistTile(
              title: playlist.name,
              cover: playlist.cover,
              subtitle: '${playlist.songIds.length} songs',
              onTap: () => Navigator.of(
                context,
              ).pushNamed(Routes.playlist, arguments: MediaArgs(playlist.id)),
              onMenu: () => showPlaylistOptions(context, playlist),
            ),
          ],
        ],
      ),
    );
  }

  static List<Playlist> _sorted(List<Playlist> source, SongSort sort) =>
      switch (sort) {
        SongSort.recent => [
          ...source,
        ]..sort((a, b) => a.createdOrder.compareTo(b.createdOrder)),
        SongSort.title || SongSort.ascending => [
          ...source,
        ]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase())),
        SongSort.descending => [
          ...source,
        ]..sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase())),
        SongSort.duration => [
          ...source,
        ]..sort((a, b) => b.songIds.length.compareTo(a.songIds.length)),
      };
}

/// `28_playlist option menu` — the row overflow sheet for one playlist.
void showPlaylistOptions(BuildContext context, Playlist playlist) {
  final library = context.read<LibraryStore>();
  final songs = MusicLibrary.songsByIds(playlist.songIds);

  void playNextAll() {
    // Inserted back-to-front so the queue keeps the playlist's own order.
    final player = context.read<PlayerController>();
    for (final song in songs.reversed) {
      player.playNext(song);
    }
  }

  void enqueueAll() {
    final player = context.read<PlayerController>();
    for (final song in songs) {
      player.addToQueue(song);
    }
  }

  void withSongs(void Function() action) {
    if (songs.isEmpty) {
      showSnack(context, '${playlist.name} has no songs yet.');
      return;
    }
    action();
  }

  showMumeSheet(
    context,
    builder: (ctx) => MumeSheet(
      title: playlist.name,
      children: [
        OptionTile(
          icon: Icons.playlist_play_rounded,
          label: 'Play Next',
          onTap: () {
            Navigator.of(ctx).pop();
            withSongs(playNextAll);
          },
        ),
        OptionTile(
          icon: Icons.playlist_add_rounded,
          label: 'Add to Playing Queue',
          onTap: () {
            Navigator.of(ctx).pop();
            withSongs(enqueueAll);
          },
        ),
        OptionTile(
          icon: Icons.edit_outlined,
          label: 'Edit',
          onTap: () {
            Navigator.of(ctx).pop();
            Navigator.of(
              context,
            ).pushNamed(Routes.newPlaylist, arguments: MediaArgs(playlist.id));
          },
        ),
        OptionTile(
          icon: Icons.share_outlined,
          label: 'Share',
          onTap: () {
            Navigator.of(ctx).pop();
            showSnack(
              context,
              'Sharing ${playlist.name} is not part of this demo.',
            );
          },
        ),
        OptionTile(
          icon: Icons.delete_outline_rounded,
          label: 'Delete',
          destructive: true,
          onTap: () {
            Navigator.of(ctx).pop();
            confirmDeletePlaylist(context, library, playlist);
          },
        ),
      ],
    ),
  );
}

Future<bool> confirmDeletePlaylist(
  BuildContext context,
  LibraryStore library,
  Playlist playlist,
) async {
  final confirmed = await confirmDialog(
    context,
    title: 'Delete playlist?',
    message:
        '${playlist.name} and its ${playlist.songIds.length} songs will be removed.',
    confirmLabel: 'Delete',
  );
  if (confirmed) library.deletePlaylist(playlist.id);
  return confirmed;
}

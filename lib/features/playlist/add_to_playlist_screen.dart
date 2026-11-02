import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimens.dart';
import '../../app/theme/app_theme.dart';
import '../../app/theme/app_typography.dart';
import '../../app/widgets/page.dart';
import '../../app/widgets/sheets.dart';
import '../../app/widgets/song_option_sheet.dart';
import '../../app/widgets/tiles.dart';
import '../../data/library_store.dart';
import '../../data/models/media.dart';
import '../../data/music_library.dart';

/// `29_add song to playlist` — which boards already hold this track and a
/// direct route to file it into a new one.
class AddToPlaylistScreen extends StatelessWidget {
  const AddToPlaylistScreen({super.key, required this.songId});

  final String songId;

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryStore>();
    final song = MusicLibrary.songById(songId);
    final included = library.playlistsContaining(songId);

    return Scaffold(
      appBar: PageTopBar(title: 'Add to Playlist'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
            Insets.page, Insets.gapSm, Insets.page, Insets.gap2xl),
        children: [
          SongSheetHeader(
            title: song.title,
            subtitle: '${song.artist}  |  ${song.durationLabel} mins',
            cover: song.cover,
            favorited: library.isFavorite(song.id),
            onFavorite: () => library.toggleFavorite(song.id),
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
                    child: const Icon(Icons.add_rounded,
                        color: AppColors.white, size: 30),
                  ),
                  const SizedBox(width: Insets.gapLg),
                  Text(
                    'New Playlist',
                    style: AppTypography.body(
                      AppTypography.bodyXLarge,
                      weight: FontWeight.w700,
                      color: context.inkPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (library.playlists.isEmpty)
            const EmptyState(
              title: 'No playlists yet',
              message:
                  'Create a playlist first and this song will have somewhere to live.',
              icon: Icons.playlist_add_rounded,
            )
          else
            for (final playlist in library.playlists) ...[
              Divider(color: context.separatorColor),
              PlaylistTile(
                title: playlist.name,
                cover: playlist.cover,
                subtitle: '${playlist.songIds.length} songs',
                onTap: () => _toggle(context, playlist),
                trailing: _PickMark(
                  added: included.contains(playlist.id),
                  onTap: () => _toggle(context, playlist),
                ),
              ),
            ],
        ],
      ),
    );
  }

  void _toggle(BuildContext context, Playlist playlist) {
    final library = context.read<LibraryStore>();
    if (!playlist.songIds.contains(songId)) {
      library.addToPlaylist(playlist.id, songId);
      Navigator.of(context).pop();
      return;
    }
    library.removeFromPlaylist(playlist.id, songId);
    showSnack(context,
        '${MusicLibrary.songById(songId).title} removed from ${playlist.name}');
  }
}

/// Orange square = not in this playlist yet, outlined tick = already filed.
class _PickMark extends StatelessWidget {
  const _PickMark({required this.added, this.onTap});

  final bool added;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      tooltip: added ? 'Remove from this playlist' : 'Add to this playlist',
      icon: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: added ? Colors.transparent : AppColors.primary,
          borderRadius: BorderRadius.circular(Insets.radiusSm),
          border: Border.all(color: AppColors.primary, width: 1.6),
        ),
        child: Icon(
          added ? Icons.check_rounded : Icons.add_rounded,
          size: 20,
          color: added ? AppColors.primary : AppColors.white,
        ),
      ),
    );
  }
}

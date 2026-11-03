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
  const AddToPlaylistScreen({
    super.key,
    required this.songId,
    this.songIds = const [],
  });

  final String songId;
  final List<String> songIds;

  List<String> get _songIds => songIds.isEmpty ? [songId] : songIds;

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryStore>();
    final songs = MusicLibrary.songsByIds(_songIds);
    final song = songs.first;
    final included = library.playlists
        .where((playlist) => _songIds.every(playlist.songIds.contains))
        .map((playlist) => playlist.id)
        .toSet();

    return Scaffold(
      appBar: PageTopBar(title: 'Add to Playlist'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Insets.page,
          Insets.gapSm,
          Insets.page,
          Insets.gap2xl,
        ),
        children: [
          SongSheetHeader(
            title: songs.length == 1 ? song.title : '${songs.length} Songs',
            subtitle: songs.length == 1
                ? '${song.artist}  |  ${song.durationLabel} mins'
                : song.artist,
            cover: song.cover,
            favorited: songs.length == 1 && library.isFavorite(song.id),
            onFavorite: songs.length == 1
                ? () => library.toggleFavorite(song.id)
                : null,
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
              message: 'Create a playlist first and this song will have somewhere to live.',
              icon: Icons.playlist_add_rounded,
            )
          else
            for (final playlist in library.playlists) ...[
              PlaylistTile(
                title: playlist.name,
                cover: playlist.cover,
                subtitle: '${playlist.songIds.length} songs',
                onTap: () => _toggle(context, playlist),
                trailing: PickMark(
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
    if (!_songIds.every(playlist.songIds.contains)) {
      for (final id in _songIds) {
        library.addToPlaylist(playlist.id, id);
      }
      Navigator.of(context).pop();
      return;
    }
    for (final id in _songIds) {
      library.removeFromPlaylist(playlist.id, id);
    }
    showSnack(context, 'Selection removed from ${playlist.name}');
  }
}

/// Orange square = not in this playlist yet, outlined tick = already filed.
class PickMark extends StatelessWidget {
  const PickMark({super.key, required this.added, this.onTap});

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

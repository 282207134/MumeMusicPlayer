import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/library_store.dart';
import '../../data/models/media.dart';
import '../../data/music_library.dart';
import '../../data/player_controller.dart';
import '../router.dart';
import '../theme/app_dimens.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';
import 'app_logo.dart';
import 'sheets.dart';
import 'tiles.dart';

/// Opens the shared song overflow sheet (`8_home song option`).
Future<void> showSongOptions(BuildContext context, Song song) => showMumeSheet(
      context,
      builder: (_) => SongOptionSheet(song: song),
    );

class SongOptionSheet extends StatelessWidget {
  const SongOptionSheet({super.key, required this.song});

  final Song song;

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryStore>();
    final player = context.read<PlayerController>();

    void run(void Function() action) {
      Navigator.of(context).pop();
      action();
    }

    return MumeSheet(
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SongSheetHeader(
            title: song.title,
            subtitle: '${song.artist}  |  ${song.durationLabel} mins',
            cover: song.cover,
            favorited: library.isFavorite(song.id),
            onFavorite: () => library.toggleFavorite(song.id),
          ),
          const SizedBox(height: Insets.gapMd),
          Divider(color: context.separatorColor),
          const SizedBox(height: Insets.gapSm),
        ],
      ),
      children: [
        OptionTile(
          icon: Icons.playlist_play_rounded,
          label: 'Play Next',
          onTap: () => run(() => player.playNext(song)),
        ),
        OptionTile(
          icon: Icons.playlist_add_rounded,
          label: 'Add to Playing Queue',
          onTap: () => run(() => player.addToQueue(song)),
        ),
        OptionTile(
          icon: Icons.add_circle_outline_rounded,
          label: 'Add to Playlist',
          onTap: () => run(() => Navigator.of(context)
              .pushNamed(Routes.addToPlaylist, arguments: MediaArgs(song.id))),
        ),
        OptionTile(
          icon: Icons.album_outlined,
          label: 'Go to Album',
          onTap: () => run(() => Navigator.of(context).pushNamed(
              Routes.album, arguments: MediaArgs(MusicLibrary.albumOfSong(song).id))),
        ),
        OptionTile(
          icon: Icons.person_outline_rounded,
          label: 'Go to Artist',
          onTap: () => run(() => Navigator.of(context).pushNamed(
              Routes.artist,
              arguments: MediaArgs(MusicLibrary.artistOfSong(song).id))),
        ),
        OptionTile(
          icon: Icons.info_outline_rounded,
          label: 'Details',
          onTap: () => run(() => showSongDetails(context, song)),
        ),
        const OptionTile(
          icon: Icons.phone_outlined,
          label: 'Set as Ringtone',
        ),
        const OptionTile(
          icon: Icons.block_rounded,
          label: 'Add to Blacklist',
        ),
        const OptionTile(
          icon: Icons.send_outlined,
          label: 'Share',
        ),
        OptionTile(
          icon: Icons.delete_outline_rounded,
          label: 'Delete from Device',
          destructive: true,
          onTap: () => run(() => showSnack(
              context, '${song.title} removed from this device (demo)')),
        ),
      ],
    );
  }
}

void showSongDetails(BuildContext context, Song song) {
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(song.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CoverArt(asset: song.cover, size: 96, radius: Insets.radiusLg),
          const SizedBox(height: Insets.gapLg),
          Text('Artist: ${song.artist}',
              style: AppTypography.body(AppTypography.bodyLarge,
                  color: ctx.inkMuted)),
          Text('Album: ${song.album}',
              style: AppTypography.body(AppTypography.bodyLarge,
                  color: ctx.inkMuted)),
          Text('Duration: ${song.durationLabel} mins',
              style: AppTypography.body(AppTypography.bodyLarge,
                  color: ctx.inkMuted)),
          if (song.releaseYear != null)
            Text('Released: ${song.releaseYear}',
                style: AppTypography.body(AppTypography.bodyLarge,
                    color: ctx.inkMuted)),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
      ],
    ),
  );
}

void showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(Insets.gapLg),
    ));
}

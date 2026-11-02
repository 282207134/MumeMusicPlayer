import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/router.dart';
import '../../app/theme/app_dimens.dart';
import '../../app/theme/app_theme.dart';
import '../../app/theme/app_typography.dart';
import '../../app/widgets/app_logo.dart';
import '../../app/widgets/buttons.dart';
import '../../app/widgets/page.dart';
import '../../app/widgets/song_option_sheet.dart';
import '../../app/widgets/tiles.dart';
import '../../data/library_store.dart';
import '../../data/models/media.dart';
import '../../data/music_library.dart';
import '../../data/player_controller.dart';

/// `16_Light_album details` — centred artwork, transport pills, track list.
class AlbumDetailsScreen extends StatefulWidget {
  const AlbumDetailsScreen({super.key, required this.albumId});

  final String albumId;

  @override
  State<AlbumDetailsScreen> createState() => _AlbumDetailsScreenState();
}

class _AlbumDetailsScreenState extends State<AlbumDetailsScreen> {
  static const _preview = 3;

  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryStore>();
    final player = context.watch<PlayerController>();
    final album = MusicLibrary.albumById(widget.albumId);
    final songs = MusicLibrary.songsByIds(album.songIds);
    final more = songs.length > _preview;
    final shown = _expanded || !more ? songs : songs.take(_preview).toList();
    final total =
        songs.fold<Duration>(Duration.zero, (sum, s) => sum + s.duration);

    return MumePage(
      topBar: PageTopBar(
        actions: [
          GhostIconButton(
            icon: Icons.search_rounded,
            tooltip: 'Search',
            onPressed: () => Navigator.of(context).pushNamed(Routes.search),
          ),
          OutlinedIconButton(
            icon: Icons.circle_outlined,
            tooltip: 'Toggle theme',
            onPressed: () => library.darkMode = !library.darkMode,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Hero(
              tag: 'cover-${songs.first.id}',
              child: CoverArt(
                asset: album.cover,
                size: Insets.coverGrid * 2 + 12,
                radius: Insets.radiusXl,
              ),
            ),
          ),
          const SizedBox(height: Insets.gapXl),
          Text(
            album.title,
            textAlign: TextAlign.center,
            style: AppTypography.heading(AppTypography.h4,
                color: context.inkPrimary),
          ),
          const SizedBox(height: Insets.gapSm),
          Text(
            '${album.artist}  |  ${album.year ?? '-'}',
            textAlign: TextAlign.center,
            style: AppTypography.body(AppTypography.bodyLarge,
                weight: FontWeight.w600, color: context.inkMuted),
          ),
          const SizedBox(height: Insets.gapSm),
          Text(
            '1 Album  |  ${songs.length} Songs  |  '
            '${formatClock(total).padLeft(8, '0')} mins',
            textAlign: TextAlign.center,
            style: AppTypography.body(
                AppTypography.bodyMedium, color: context.inkSoft),
          ),
          const SizedBox(height: Insets.gapXl),
          Row(
            children: [
              Expanded(
                child: PrimaryPillButton(
                  label: 'Shuffle',
                  icon: Icons.shuffle_rounded,
                  onPressed: () => _start(songs, shuffle: true),
                ),
              ),
              const SizedBox(width: Insets.gapLg),
              Expanded(
                child: SoftPillButton(
                  label: 'Play',
                  icon: Icons.play_circle_fill_rounded,
                  onPressed: () => _start(songs, shuffle: false),
                ),
              ),
            ],
          ),
          const SizedBox(height: Insets.gapXl),
          Divider(color: context.separatorColor),
          const SizedBox(height: Insets.gapLg),
          SectionHeader(
            title: 'Songs',
            actionLabel: more ? (_expanded ? 'Show Less' : 'See All') : null,
            onAction: more ? () => setState(() => _expanded = !_expanded) : null,
          ),
          for (var i = 0; i < shown.length; i++) ...[
            if (i > 0) Divider(color: context.separatorColor),
            SongTile(
              song: shown[i],
              active: player.current?.id == shown[i].id && player.isPlaying,
              onTap: () => _play(shown, i),
              onPlay: () => _play(shown, i),
              onMenu: () => showSongOptions(context, shown[i]),
            ),
          ],
        ],
      ),
    );
  }

  void _start(List<Song> queue, {required bool shuffle}) {
    final player = context.read<PlayerController>();
    player.playQueue(queue, 0);
    if (shuffle && !player.shuffle) player.toggleShuffle();
    context.read<LibraryStore>().markPlayed(queue.first.id);
    Navigator.of(context).pushNamed(Routes.player);
  }

  void _play(List<Song> queue, int index) {
    final library = context.read<LibraryStore>();
    context.read<PlayerController>().playQueue(queue, index);
    library.markPlayed(queue[index].id);
    Navigator.of(context).pushNamed(Routes.player);
  }
}

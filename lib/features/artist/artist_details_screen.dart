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

/// `14_Light_artist details` — art, transport pills, then songs and albums.
class ArtistDetailsScreen extends StatelessWidget {
  const ArtistDetailsScreen({super.key, required this.artistId});

  final String artistId;

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryStore>();
    final artist = MusicLibrary.artistById(artistId);
    final songs = MusicLibrary.songsByIds(artist.songIds);
    final albums = MusicLibrary.albumsOf(artist.id);

    return MumePage(
      topBar: PageTopBar(
        actions: [
          GhostIconButton(
            icon: Icons.search_rounded,
            tooltip: 'Search',
            onPressed: () =>
                Navigator.of(context).pushNamed(Routes.search),
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
            child: CoverArt(
              asset: artist.cover,
              size: Insets.coverGrid * 2 + 12,
              circular: true,
            ),
          ),
          const SizedBox(height: Insets.gapXl),
          Text(
            artist.name,
            textAlign: TextAlign.center,
            style: AppTypography.heading(AppTypography.h4,
                color: context.inkPrimary),
          ),
          const SizedBox(height: Insets.gapSm),
          Text(
            _credit(albums.length, songs),
            textAlign: TextAlign.center,
            style: AppTypography.body(AppTypography.bodyLarge,
                color: context.inkMuted),
          ),
          const SizedBox(height: Insets.gapXl),
          _ShufflePlay(songs: songs),
          const SizedBox(height: Insets.gapXl),
          Divider(color: context.separatorColor),
          const SizedBox(height: Insets.gapLg),
          _SongsSection(songs: songs),
          if (albums.isNotEmpty) ...[
            const SectionHeader(
              title: 'Albums',
              padding: EdgeInsets.only(
                  top: Insets.gapXl, bottom: Insets.gapLg),
            ),
            _AlbumGrid(albums: albums),
          ],
        ],
      ),
    );
  }
}

/// `1 Album | 20 Songs | 01:25:43 mins` — the kit's artist credit line.
String _credit(int albumCount, List<Song> songs) {
  final total =
      songs.fold<Duration>(Duration.zero, (sum, s) => sum + s.duration);
  return '$albumCount Album${albumCount == 1 ? '' : 's'}  |  '
      '${songs.length} Songs  |  ${formatClock(total).padLeft(8, '0')} mins';
}

/// The two header pills: solid orange shuffle, tinted play.
class _ShufflePlay extends StatelessWidget {
  const _ShufflePlay({required this.songs});

  final List<Song> songs;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: PrimaryPillButton(
            label: 'Shuffle',
            icon: Icons.shuffle_rounded,
            onPressed: () => _start(context, shuffle: true),
          ),
        ),
        const SizedBox(width: Insets.gapLg),
        Expanded(
          child: SoftPillButton(
            label: 'Play',
            icon: Icons.play_circle_fill_rounded,
            onPressed: () => _start(context, shuffle: false),
          ),
        ),
      ],
    );
  }

  void _start(BuildContext context, {required bool shuffle}) {
    final player = context.read<PlayerController>();
    player.playQueue(songs, 0);
    if (shuffle && !player.shuffle) player.toggleShuffle();
    context.read<LibraryStore>().markPlayed(songs.first.id);
    Navigator.of(context).pushNamed(Routes.player);
  }
}

/// Two-up album grid. `AlbumCell` asks for an infinite cover, which a grid cell
/// cannot give, so the square is measured from the available width instead.
class _AlbumGrid extends StatelessWidget {
  const _AlbumGrid({required this.albums});

  final List<Album> albums;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = (constraints.maxWidth - Insets.gapLg) / 2;
        return GridView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: Insets.gapLg,
            mainAxisSpacing: Insets.gapXl,
            mainAxisExtent: side + 60,
          ),
          itemCount: albums.length,
          itemBuilder: (context, i) => InkWell(
            borderRadius: BorderRadius.circular(Insets.radiusXl),
            onTap: () => Navigator.of(context).pushNamed(
                Routes.album, arguments: MediaArgs(albums[i].id)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CoverArt(
                    asset: albums[i].cover,
                    size: side,
                    radius: Insets.radiusXl),
                const SizedBox(height: Insets.gapMd),
                Text(
                  albums[i].title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body(AppTypography.bodyLarge,
                      weight: FontWeight.w700, color: context.inkPrimary),
                ),
                Text(
                  albums[i].artist,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body(AppTypography.bodyMedium,
                      color: context.inkMuted),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// `Songs` rail that folds the tail of the list behind `See All`.
class _SongsSection extends StatefulWidget {
  const _SongsSection({required this.songs});

  final List<Song> songs;

  @override
  State<_SongsSection> createState() => _SongsSectionState();
}

class _SongsSectionState extends State<_SongsSection> {
  static const _preview = 3;

  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerController>();
    final more = widget.songs.length > _preview;
    final shown = _expanded || !more
        ? widget.songs
        : widget.songs.take(_preview).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
    );
  }

  void _play(List<Song> queue, int index) {
    final library = context.read<LibraryStore>();
    context.read<PlayerController>().playQueue(queue, index);
    library.markPlayed(queue[index].id);
    Navigator.of(context).pushNamed(Routes.player);
  }
}

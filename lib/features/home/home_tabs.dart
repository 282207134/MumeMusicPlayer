import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/router.dart';
import '../../app/theme/app_dimens.dart';
import '../../app/theme/app_theme.dart';
import '../../app/theme/app_typography.dart';
import '../../app/widgets/app_logo.dart';
import '../../app/widgets/buttons.dart';
import '../../app/widgets/detail_sections.dart';
import '../../app/widgets/sheets.dart';
import '../../app/widgets/song_option_sheet.dart';
import '../../app/widgets/sort_menu.dart';
import '../../app/widgets/tiles.dart';
import '../../data/library_store.dart';
import '../../data/models/media.dart';
import '../../data/music_library.dart';
import '../../data/player_controller.dart';

/// `5_Light_home suggested` — three horizontal rails.
class SuggestedTab extends StatelessWidget {
  const SuggestedTab({super.key, this.onArtistsSeeAll});

  final VoidCallback? onArtistsSeeAll;

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryStore>();
    const headerPad = EdgeInsets.fromLTRB(
      Insets.page,
      Insets.gapLg,
      Insets.page,
      Insets.gapLg,
    );
    return ListView(
      padding: const EdgeInsets.only(bottom: Insets.gap2xl),
      children: [
        SectionHeader(
          padding: headerPad,
          title: 'Recently Played',
          actionLabel: 'See All',
          onAction: () =>
              Navigator.of(context).pushNamed(Routes.recentlyPlayed),
        ),
        _CoverRail(
          items: [
            for (final song in library.recentlyPlayed)
              _RailItem(
                cover: song.cover,
                caption: '${song.title} - ${song.artist}',
                onTap: () => _play(context, library.recentlyPlayed, song),
              ),
          ],
        ),
        const SizedBox(height: Insets.gapXl),
        SectionHeader(
          padding: headerPad,
          title: 'Artists',
          actionLabel: 'See All',
          onAction: onArtistsSeeAll,
        ),
        _CoverRail(
          circular: true,
          items: [
            for (final artist in MusicLibrary.artists)
              _RailItem(
                cover: artist.cover,
                caption: artist.name,
                onTap: () => Navigator.of(context)
                    .pushNamed(Routes.artist, arguments: MediaArgs(artist.id)),
              ),
          ],
        ),
        const SizedBox(height: Insets.gapXl),
        SectionHeader(
          padding: headerPad,
          title: 'Most Played',
          actionLabel: 'See All',
          onAction: () =>
              Navigator.of(context).pushNamed(Routes.recentlyPlayed),
        ),
        _CoverRail(
          items: [
            for (final song in MusicLibrary.mostPlayed)
              _RailItem(
                cover: song.cover,
                caption: '${song.title} - ${song.artist}',
                onTap: () => _play(context, MusicLibrary.mostPlayed, song),
              ),
          ],
        ),
      ],
    );
  }

  static void _play(BuildContext context, List<Song> queue, Song song) =>
      playSongs(context, queue, queue.indexOf(song));
}

class _CoverRail extends StatelessWidget {
  const _CoverRail({required this.items, this.circular = false});

  final List<_RailItem> items;
  final bool circular;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: circular ? Insets.coverGrid + 44 : Insets.coverGrid + 76,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: Insets.page),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: Insets.gapLg),
        itemBuilder: (context, i) => SizedBox(
          width: Insets.coverGrid,
          child: circular
              ? ArtistCell(
                  name: items[i].caption,
                  cover: items[i].cover,
                  size: Insets.coverGrid,
                  onTap: items[i].onTap,
                )
              : _square(context, items[i]),
        ),
      ),
    );
  }

  Widget _square(BuildContext context, _RailItem item) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      CoverArt(
        asset: item.cover,
        size: Insets.coverGrid,
        radius: Insets.radiusXl,
      ),
      const SizedBox(height: Insets.gapMd),
      Expanded(
        child: Text(
          item.caption,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.body(
            AppTypography.bodyLarge,
            weight: FontWeight.w700,
            color: context.inkPrimary,
          ),
        ),
      ),
    ],
  );
}

class _RailItem {
  const _RailItem({
    required this.cover,
    required this.caption,
    required this.onTap,
  });

  final String cover;
  final String caption;
  final VoidCallback onTap;
}

/// `6_Light_home songs` + `7_home songs sort option`.
class SongsTab extends StatefulWidget {
  const SongsTab({super.key});

  @override
  State<SongsTab> createState() => _SongsTabState();
}

class _SongsTabState extends State<SongsTab> {
  static const _choices = <SortChoice<SongSort>>[
    SortChoice(SongSort.ascending, 'Ascending'),
    SortChoice(SongSort.descending, 'Descending'),
    SortChoice(SongSort.title, 'Artist'),
    SortChoice(SongSort.title, 'Album'),
    SortChoice(SongSort.title, 'Year'),
    SortChoice(SongSort.recent, 'Date Added'),
    SortChoice(SongSort.duration, 'Date Modified'),
    SortChoice(SongSort.title, 'Composer'),
  ];

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryStore>();
    final player = context.watch<PlayerController>();
    final songs = library.sortedSongs(MusicLibrary.songs);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Insets.page),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CountSortBar(
            count: MusicLibrary.songCountLabel,
            sortLabel: library.songSort.label,
            onSort: (anchor) async {
              final picked = await showSortMenu<SongSort>(
                anchor,
                choices: _choices,
                selected: library.songSort,
              );
              if (picked != null) library.songSort = picked;
            },
          ),
          Divider(color: context.separatorColor),
          Expanded(
            child: ListView.builder(
              itemCount: songs.length,
              itemBuilder: (context, i) {
                final song = songs[i];
                return SongTile(
                  song: song,
                  showDuration: true,
                  active: player.current?.id == song.id && player.isPlaying,
                  onTap: () => player.playQueue(songs, i),
                  onPlay: () {
                    if (player.current?.id == song.id) {
                      player.toggle();
                    } else {
                      player.playQueue(songs, i);
                      library.markPlayed(song.id);
                    }
                  },
                  onMenu: () => showSongOptions(context, song),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// `12_Light_home artists` — list rows with circular art.
class ArtistsTab extends StatelessWidget {
  const ArtistsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Insets.page),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CountSortBar(count: '85 artists', sortLabel: 'Date Added'),
          Divider(color: context.separatorColor),
          Expanded(
            child: ListView.builder(
              itemCount: MusicLibrary.artists.length,
              itemBuilder: (context, i) {
                final artist = MusicLibrary.artists[i];
                final albums = artist.albumIds.length;
                return PlaylistTile(
                  title: artist.name,
                  cover: artist.cover,
                  circular: true,
                  coverSize: Insets.coverTile,
                  subtitle:
                      '$albums Album${albums == 1 ? '' : 's'}  |  ${artist.songIds.length * 4 + 4} Songs',
                  onTap: () => Navigator.of(
                    context,
                  ).pushNamed(Routes.artist, arguments: MediaArgs(artist.id)),
                  onMenu: () => showMediaOptions(
                    context,
                    title: artist.name,
                    subtitle:
                        '$albums Album${albums == 1 ? '' : 's'}  |  ${artist.songIds.length * 4 + 4} Songs',
                    cover: artist.cover,
                    songIds: artist.songIds,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// `13_Light_home artist option` — the ⋮ sheet shared by artists and albums.
void showMediaOptions(
  BuildContext context, {
  required String title,
  required String subtitle,
  required String cover,
  required List<String> songIds,
}) {
  showMumeSheet(
    context,
    builder: (ctx) {
      final songs = MusicLibrary.songsByIds(songIds);
      final player = ctx.read<PlayerController>();

      void run(VoidCallback action) {
        Navigator.of(ctx).pop();
        action();
      }

      return MumeSheet(
        header: Column(
          children: [
            SongSheetHeader(title: title, subtitle: subtitle, cover: cover),
            Divider(color: ctx.separatorColor),
          ],
        ),
        children: [
          OptionTile(
            icon: Icons.play_arrow_rounded,
            label: 'Play',
            onTap: () => run(() {
              player.playQueue(songs, 0);
              Navigator.of(ctx).pushNamed(Routes.player);
            }),
          ),
          OptionTile(
            icon: Icons.playlist_play_rounded,
            label: 'Play Next',
            onTap: () => run(() {
              for (final song in songs.reversed) {
                player.playNext(song);
              }
            }),
          ),
          OptionTile(
            icon: Icons.playlist_add_rounded,
            label: 'Add to Playing Queue',
            onTap: () => run(() {
              for (final song in songs) {
                player.addToQueue(song);
              }
            }),
          ),
          OptionTile(
            icon: Icons.add_circle_outline_rounded,
            label: 'Add to Playlist',
            onTap: () => run(
              () => Navigator.of(ctx).pushNamed(
                Routes.addToPlaylist,
                arguments: MediaArgs(songIds.first, extra: songIds.join(',')),
              ),
            ),
          ),
          OptionTile(
            icon: Icons.share_outlined,
            label: 'Share',
            onTap: () => run(() => showSnack(ctx, 'Link to $title copied')),
          ),
        ],
      );
    },
  );
}

/// `15_Light_home albums` — two-up grid.
class AlbumsTab extends StatelessWidget {
  const AlbumsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Insets.page),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CountSortBar(count: '68 albums', sortLabel: 'Date Modified'),
          Divider(color: context.separatorColor),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.66,
                crossAxisSpacing: Insets.gapLg,
                mainAxisSpacing: Insets.gapXl,
              ),
              itemCount: MusicLibrary.albums.length,
              itemBuilder: (context, i) =>
                  _AlbumCard(album: MusicLibrary.albums[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlbumCard extends StatelessWidget {
  const _AlbumCard({required this.album});

  final Album album;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () =>
          Navigator.of(context)
              .pushNamed(Routes.album, arguments: MediaArgs(album.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: CoverArt(asset: album.cover, radius: Insets.radiusXl),
          ),
          const SizedBox(height: Insets.gapMd),
          Row(
            children: [
              Expanded(
                child: Text(
                  album.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body(
                    AppTypography.bodyLarge,
                    weight: FontWeight.w700,
                    color: context.inkPrimary,
                  ),
                ),
              ),
              GhostIconButton(
                icon: Icons.more_vert_rounded,
                size: 20,
                onPressed: () => showMediaOptions(
                  context,
                  title: album.title,
                  subtitle: '${album.artist}  |  ${album.songIds.length} Songs',
                  cover: album.cover,
                  songIds: album.songIds,
                ),
              ),
            ],
          ),
          Text(
            '${album.artist}  |  ${album.year ?? '-'}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.body(
              AppTypography.bodyMedium,
              color: context.inkMuted,
            ),
          ),
          Text(
            '${album.songIds.length * 4} songs',
            style: AppTypography.body(
              AppTypography.bodyMedium,
              color: context.inkMuted,
            ),
          ),
        ],
      ),
    );
  }
}

/// `17_Light_home folders`.
class FoldersTab extends StatelessWidget {
  const FoldersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Insets.page),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CountSortBar(count: '40 folders', sortLabel: 'Date Added'),
          Divider(color: context.separatorColor),
          Expanded(
            child: ListView.builder(
              itemCount: MusicLibrary.folders.length,
              itemBuilder: (context, i) {
                final folder = MusicLibrary.folders[i];
                return InkWell(
                  onTap: () => Navigator.of(
                    context,
                  ).pushNamed(Routes.folder, arguments: MediaArgs(folder.id)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: Insets.gapLg),
                    child: Row(
                      children: [
                        const FolderGlyph(),
                        const SizedBox(width: Insets.gapLg),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                folder.name,
                                style: AppTypography.body(
                                  AppTypography.bodyXLarge,
                                  weight: FontWeight.w700,
                                  color: context.inkPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${folder.songIds.length * 20} songs',
                                style: AppTypography.body(
                                  AppTypography.bodyMedium,
                                  color: context.inkMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GhostIconButton(
                          icon: Icons.more_vert_rounded,
                          size: 22,
                          onPressed: () => showMediaOptions(
                            context,
                            title: folder.name,
                            subtitle: folder.path,
                            cover: MusicLibrary.songById(folder.songIds.first)
                                .cover,
                            songIds: folder.songIds,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

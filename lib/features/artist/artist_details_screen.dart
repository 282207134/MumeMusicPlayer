import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/router.dart';
import '../../app/theme/app_dimens.dart';
import '../../app/theme/app_theme.dart';
import '../../app/theme/app_typography.dart';
import '../../app/widgets/app_logo.dart';
import '../../app/widgets/buttons.dart';
import '../../app/widgets/detail_sections.dart';
import '../../app/widgets/page.dart';
import '../../app/widgets/tiles.dart';
import '../../data/library_store.dart';
import '../../data/models/media.dart';
import '../../data/music_library.dart';

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
    final total = songs.fold<Duration>(
      Duration.zero,
      (sum, s) => sum + s.duration,
    );

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
            child: CoverArt(
              asset: artist.cover,
              size: Insets.coverDetail,
              radius: Insets.radiusDetailCover,
            ),
          ),
          const SizedBox(height: Insets.gapXl),
          Text(
            artist.name,
            textAlign: TextAlign.center,
            style: AppTypography.heading(
              AppTypography.h4,
              color: context.inkPrimary,
            ),
          ),
          const SizedBox(height: Insets.gapSm),
          Text(
            '${albums.length} Album${albums.length == 1 ? '' : 's'}  |  '
            '${songs.length} Songs  |  ${formatTotal(total)} mins',
            textAlign: TextAlign.center,
            style: AppTypography.body(
              AppTypography.bodyLarge,
              color: context.inkMuted,
            ),
          ),
          const SizedBox(height: Insets.gapXl),
          ShufflePlayRow(songs: songs),
          const SizedBox(height: Insets.gapXl),
          Divider(color: context.separatorColor),
          const SizedBox(height: Insets.gapLg),
          SongsSection(songs: songs),
          if (albums.isNotEmpty) ...[
            const SectionHeader(
              title: 'Albums',
              padding: EdgeInsets.only(top: Insets.gapXl, bottom: Insets.gapLg),
            ),
            _AlbumGrid(albums: albums),
          ],
        ],
      ),
    );
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
            onTap: () => Navigator.of(context)
                .pushNamed(Routes.album, arguments: MediaArgs(albums[i].id)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CoverArt(
                  asset: albums[i].cover,
                  size: side,
                  radius: Insets.radiusXl,
                ),
                const SizedBox(height: Insets.gapMd),
                Text(
                  albums[i].title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body(
                    AppTypography.bodyLarge,
                    weight: FontWeight.w700,
                    color: context.inkPrimary,
                  ),
                ),
                Text(
                  albums[i].artist,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body(
                    AppTypography.bodyMedium,
                    color: context.inkMuted,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

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
import '../../data/library_store.dart';
import '../../data/models/media.dart';
import '../../data/music_library.dart';

/// `16_Light_album details` — centred artwork, transport pills, track list.
class AlbumDetailsScreen extends StatelessWidget {
  const AlbumDetailsScreen({super.key, required this.albumId});

  final String albumId;

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryStore>();
    final album = MusicLibrary.albumById(albumId);
    final songs = MusicLibrary.songsByIds(album.songIds);
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
            child: Hero(
              tag: 'cover-${songs.first.id}',
              child: CoverArt(
                asset: album.cover,
                size: Insets.coverDetail,
                radius: Insets.radiusDetailCover,
              ),
            ),
          ),
          const SizedBox(height: Insets.gapXl),
          Text(
            album.title,
            textAlign: TextAlign.center,
            style: AppTypography.heading(
              AppTypography.h4,
              color: context.inkPrimary,
            ),
          ),
          const SizedBox(height: Insets.gapSm),
          Text(
            '1 Album  |  ${songs.length} Songs  |  ${formatTotal(total)} mins',
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
        ],
      ),
    );
  }
}

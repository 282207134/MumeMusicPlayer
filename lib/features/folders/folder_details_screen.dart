import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimens.dart';
import '../../app/theme/app_theme.dart';
import '../../app/theme/app_typography.dart';
import '../../app/widgets/buttons.dart';
import '../../app/widgets/detail_sections.dart';
import '../../app/widgets/page.dart';
import '../../app/widgets/song_option_sheet.dart';
import '../../app/widgets/tiles.dart';
import '../../data/library_store.dart';
import '../../data/models/media.dart';
import '../../data/music_library.dart';
import '../../data/player_controller.dart';

/// `18_Light_folder details` — path, artwork glyph, transport and contents.
/// The folder's albums double as its subfolders, which is what the breadcrumb
/// and the row list drill into.
class FolderDetailsScreen extends StatefulWidget {
  const FolderDetailsScreen({super.key, required this.folderId});

  final String folderId;

  @override
  State<FolderDetailsScreen> createState() => _FolderDetailsScreenState();
}

class _FolderDetailsScreenState extends State<FolderDetailsScreen> {
  String? _group;

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryStore>();
    final player = context.watch<PlayerController>();
    final folder = MusicLibrary.folderById(widget.folderId);
    final all = MusicLibrary.songsByIds(folder.songIds);
    final subfolders = <String>{for (final song in all) song.album}
        .take(folder.subfolderCount)
        .toList();
    final songs = _group == null
        ? all
        : all.where((s) => s.album == _group).toList();
    final total = songs.fold<Duration>(
      Duration.zero,
      (sum, s) => sum + s.duration,
    );
    final parts = folder.path.split('/');
    final crumbs = <Widget>[
      for (var i = 0; i < parts.length; i++)
        _crumb(
          parts[i],
          current: _group == null && i == parts.length - 1,
          onTap: i == parts.length - 1 && _group != null
              ? () => setState(() => _group = null)
              : null,
        ),
      if (_group != null) _crumb(_group!, current: true),
    ];

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
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (var i = 0; i < crumbs.length; i++) ...[
                if (i > 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Insets.gapSm,
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 13,
                      color: context.inkSoft,
                    ),
                  ),
                crumbs[i],
              ],
            ],
          ),
          const SizedBox(height: Insets.gapLg),
          Center(child: FolderGlyph(size: Insets.coverGrid * 2 - 10)),
          const SizedBox(height: Insets.gapXl),
          Text(
            folder.name,
            textAlign: TextAlign.center,
            style: AppTypography.heading(
              AppTypography.h4,
              color: context.inkPrimary,
            ),
          ),
          const SizedBox(height: Insets.gapSm),
          Text(
            '${songs.length} Songs  |  '
            '${formatTotal(total)} mins',
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
          if (subfolders.isNotEmpty) ...[
            const SectionHeader(
              title: 'Subfolders',
              padding: EdgeInsets.only(top: Insets.gapLg, bottom: Insets.gapMd),
            ),
            for (final name in subfolders)
              _subfolderRow(
                name: name,
                count: all.where((s) => s.album == name).length,
                selected: _group == name,
                onTap: () => setState(() => _group = name),
              ),
          ],
          SectionHeader(
            title: 'Songs',
            actionLabel: _group == null ? null : 'Clear',
            onAction: _group == null
                ? null
                : () => setState(() => _group = null),
            padding: const EdgeInsets.only(
              top: Insets.gapLg,
              bottom: Insets.gapMd,
            ),
          ),
          for (var i = 0; i < songs.length; i++)
            SongTile(
              song: songs[i],
              active: player.current?.id == songs[i].id && player.isPlaying,
              onTap: () => playSongs(context, songs, i),
              onPlay: () => playSongs(context, songs, i),
              onMenu: () => showSongOptions(context, songs[i]),
            ),
        ],
      ),
    );
  }

  Widget _crumb(String label, {required bool current, VoidCallback? onTap}) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Insets.radiusSm),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Insets.gapSm),
          child: Text(
            label,
            style: AppTypography.body(
              AppTypography.bodyMedium,
              weight: FontWeight.w600,
              color: current ? context.inkPrimary : context.inkMuted,
            ),
          ),
        ),
      );

  Widget _subfolderRow({
    required String name,
    required int count,
    required bool selected,
    required VoidCallback onTap,
  }) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: Insets.gapMd),
      child: Row(
        children: [
          Icon(
            selected ? Icons.folder_open_rounded : Icons.folder_rounded,
            size: 34,
            color: AppColors.primary,
          ),
          const SizedBox(width: Insets.gapMd),
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.body(
                AppTypography.bodyXLarge,
                weight: FontWeight.w600,
                color: context.inkPrimary,
              ),
            ),
          ),
          Text(
            '$count songs',
            style: AppTypography.body(
              AppTypography.bodyMedium,
              color: context.inkMuted,
            ),
          ),
        ],
      ),
    ),
  );
}

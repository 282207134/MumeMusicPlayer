import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimens.dart';
import '../../app/theme/app_theme.dart';
import '../../app/theme/app_typography.dart';
import '../../app/widgets/buttons.dart';
import '../../app/widgets/song_option_sheet.dart';
import '../../app/widgets/tiles.dart';
import '../../data/library_store.dart';
import '../../data/models/media.dart';
import '../../data/music_library.dart';
import '../../data/player_controller.dart';

/// `20..22_Light_search *` — history when idle, filtered results while typing.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const _categories = <String>['Songs', 'Artists', 'Albums', 'Folders'];

  final TextEditingController _field = TextEditingController();
  final FocusNode _focus = FocusNode();
  int _category = 0;

  @override
  void initState() {
    super.initState();
    _field.addListener(_repaint);
    _focus.addListener(_repaint);
  }

  @override
  void dispose() {
    _field
      ..removeListener(_repaint)
      ..dispose();
    _focus
      ..removeListener(_repaint)
      ..dispose();
    super.dispose();
  }

  void _repaint() => setState(() {});

  String get _query => _field.text.trim();

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryStore>();
    final player = context.watch<PlayerController>();

    return Scaffold(
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  Insets.gapSm, Insets.gapLg, Insets.page, Insets.gapLg),
              child: Row(
                children: [
                  GhostIconButton(
                    icon: Icons.arrow_back_rounded,
                    tooltip: 'Back',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: Insets.gapMd),
                  Expanded(child: _SearchField(
                    controller: _field,
                    focusNode: _focus,
                    onClear: () => _field.clear(),
                    onSubmit: () => library.pushSearch(_query),
                  )),
                ],
              ),
            ),
            if (_query.isEmpty)
              _history(library)
            else
              _results(library, player),
          ],
        ),
      ),
    );
  }

  Widget _history(LibraryStore library) {
    final recent = library.recentSearches;
    if (recent.isEmpty) {
      return const Expanded(
        child: EmptyState(
          title: 'No recent searches',
          message: 'Artists and songs you look for are listed here for next time.',
          icon: Icons.history_rounded,
        ),
      );
    }

    return Expanded(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: Insets.page),
        children: [
          SectionHeader(
            title: 'Recent Searches',
            actionLabel: 'Clear All',
            onAction: library.clearSearches,
            padding: const EdgeInsets.only(bottom: Insets.gapSm),
          ),
          Divider(color: context.separatorColor),
          for (final value in recent) _historyRow(library, value),
        ],
      ),
    );
  }

  Widget _historyRow(LibraryStore library, String value) => InkWell(
        onTap: () {
          _field.text = value;
          library.pushSearch(value);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Insets.gapMd),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body(AppTypography.bodyXLarge,
                      color: context.inkMuted),
                ),
              ),
              GhostIconButton(
                icon: Icons.close_rounded,
                size: 22,
                tooltip: 'Remove',
                onPressed: () => library.removeSearch(value),
              ),
            ],
          ),
        ),
      );

  Widget _results(LibraryStore library, PlayerController player) {
    final q = _query.toLowerCase();
    final songs = library.search(_query);
    final artists = MusicLibrary.artists
        .where((a) => a.name.toLowerCase().contains(q))
        .toList();
    final albums = MusicLibrary.albums
        .where((a) => '${a.title} ${a.artist}'.toLowerCase().contains(q))
        .toList();
    final folders = MusicLibrary.folders
        .where((f) => f.path.toLowerCase().contains(q))
        .toList();

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: Insets.page),
            child: Row(
              children: [
                for (var i = 0; i < _categories.length; i++) ...[
                  if (i > 0) const SizedBox(width: Insets.gapSm),
                  _CategoryChip(
                    label: _categories[i],
                    selected: _category == i,
                    onTap: () => setState(() => _category = i),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: Insets.gapLg),
          Expanded(
            child: switch (_category) {
              0 => _songResults(songs, player),
              1 => _artistResults(artists),
              2 => _albumResults(albums),
              _ => _folderResults(folders),
            },
          ),
        ],
      ),
    );
  }

  Widget _songResults(List<Song> songs, PlayerController player) {
    if (songs.isEmpty) return _notFound();
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: Insets.page),
      itemCount: songs.length,
      separatorBuilder: (_, _) => Divider(color: context.separatorColor),
      itemBuilder: (context, i) => SongTile(
        song: songs[i],
        active: player.current?.id == songs[i].id && player.isPlaying,
        onTap: () => _play(songs, i),
        onPlay: () => _play(songs, i),
        onMenu: () => showSongOptions(context, songs[i]),
      ),
    );
  }

  Widget _artistResults(List<Artist> artists) {
    if (artists.isEmpty) return _notFound();
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: Insets.page),
      itemCount: artists.length,
      separatorBuilder: (_, _) => Divider(color: context.separatorColor),
      itemBuilder: (context, i) {
        final artist = artists[i];
        return PlaylistTile(
          title: artist.name,
          cover: artist.cover,
          coverSize: Insets.coverTile,
          subtitle:
              '${artist.albumIds.length} Album${artist.albumIds.length == 1 ? '' : 's'}'
              '  |  ${artist.songIds.length} Songs',
          onTap: () => _go(Routes.artist, artist.id),
        );
      },
    );
  }

  Widget _albumResults(List<Album> albums) {
    if (albums.isEmpty) return _notFound();
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: Insets.page),
      itemCount: albums.length,
      separatorBuilder: (_, _) => Divider(color: context.separatorColor),
      itemBuilder: (context, i) {
        final album = albums[i];
        return PlaylistTile(
          title: album.title,
          cover: album.cover,
          coverSize: Insets.coverTile,
          subtitle:
              '${album.artist}  |  ${album.songIds.length} songs',
          onTap: () => _go(Routes.album, album.id),
        );
      },
    );
  }

  Widget _folderResults(List<Folder> folders) {
    if (folders.isEmpty) return _notFound();
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: Insets.page),
      itemCount: folders.length,
      separatorBuilder: (_, _) => Divider(color: context.separatorColor),
      itemBuilder: (context, i) {
        final folder = folders[i];
        return InkWell(
          onTap: () => _go(Routes.folder, folder.id),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: Insets.gapLg),
            child: Row(
              children: [
                const Icon(Icons.folder_rounded,
                    size: Insets.coverTile, color: AppColors.primary),
                const SizedBox(width: Insets.gapLg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        folder.name,
                        style: AppTypography.body(AppTypography.bodyXLarge,
                            weight: FontWeight.w700, color: context.inkPrimary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        folder.path,
                        style: AppTypography.body(AppTypography.bodyMedium,
                            color: context.inkMuted),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded,
                    size: 16, color: context.inkSoft),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _notFound() => const EmptyState(
        title: 'No results found',
        message:
            'Sorry, the keyword you entered cannot be found, please check again '
            'or search with another keyword.',
        icon: Icons.search_off_rounded,
      );

  void _play(List<Song> queue, int index) {
    final library = context.read<LibraryStore>();
    library.pushSearch(_query);
    context.read<PlayerController>().playQueue(queue, index);
    library.markPlayed(queue[index].id);
    Navigator.of(context).pushNamed(Routes.player);
  }

  void _go(String route, String id) {
    context.read<LibraryStore>().pushSearch(_query);
    Navigator.of(context).pushNamed(route, arguments: MediaArgs(id));
  }
}

/// The tinted query box: orange magnifier and outline while it holds focus.
class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.focusNode,
    required this.onClear,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onClear;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final focused = focusNode.hasFocus;
    return TextField(
      controller: controller,
      focusNode: focusNode,
      autofocus: true,
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => onSubmit(),
      style: AppTypography.body(AppTypography.bodyXLarge,
          weight: FontWeight.w600, color: context.inkPrimary),
      decoration: InputDecoration(
        hintText: 'Songs, artists, albums',
        hintStyle:
            AppTypography.body(AppTypography.bodyXLarge, color: context.inkSoft),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: focused ? AppColors.primary : context.inkSoft,
        ),
        suffixIcon: controller.text.isEmpty
            ? null
            : GhostIconButton(
                icon: Icons.close_rounded,
                size: 22,
                tooltip: 'Clear',
                onPressed: onClear,
              ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Insets.radiusLg),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

/// `Songs / Artists / Albums / Folders` filter pill from `22_search results`.
class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Insets.radiusPill),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: Insets.gapXl, vertical: Insets.gapMd),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(Insets.radiusPill),
          border: Border.all(color: AppColors.primary, width: 1.4),
        ),
        child: Text(
          label,
          style: AppTypography.body(
            AppTypography.bodyXLarge,
            weight: FontWeight.w700,
            color: selected ? AppColors.white : AppColors.primary,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/router.dart';
import '../../app/theme/app_theme.dart';
import '../../app/widgets/buttons.dart';
import '../../app/widgets/page.dart';
import '../../app/widgets/song_option_sheet.dart';
import '../../app/widgets/sort_menu.dart';
import '../../app/widgets/tiles.dart';
import '../../data/library_store.dart';
import '../../data/models/media.dart';
import '../../data/player_controller.dart';

/// `19_Light_recently played` — the full play history with the sort bar.
class RecentlyPlayedScreen extends StatefulWidget {
  const RecentlyPlayedScreen({super.key});

  @override
  State<RecentlyPlayedScreen> createState() => _RecentlyPlayedScreenState();
}

class _RecentlyPlayedScreenState extends State<RecentlyPlayedScreen> {
  static const _choices = <SortChoice<SongSort>>[
    SortChoice(SongSort.ascending, 'Ascending'),
    SortChoice(SongSort.descending, 'Descending'),
    SortChoice(SongSort.recent, 'Recently Added'),
    SortChoice(SongSort.duration, 'Duration'),
    SortChoice(SongSort.title, 'Title'),
  ];

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryStore>();
    final player = context.watch<PlayerController>();
    final songs = library.sortedSongs(library.recentlyPlayed);

    return MumePage(
      topBar: PageTopBar(
        title: 'Recently Played',
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
          CountSortBar(
            count: '${songs.length} songs',
            sortLabel: library.songSort.label,
            onSort: () => _pickSort(library),
          ),
          Divider(color: context.separatorColor),
          if (songs.isEmpty)
            const EmptyState(
              title: 'Nothing played yet',
              message: 'Tracks you start from Home or Search land here.',
              icon: Icons.history_rounded,
            )
          else
            for (var i = 0; i < songs.length; i++)
              SongTile(
                song: songs[i],
                active: player.current?.id == songs[i].id && player.isPlaying,
                onTap: () => _play(songs, i),
                onPlay: () => _play(songs, i),
                onMenu: () => showSongOptions(context, songs[i]),
              ),
        ],
      ),
    );
  }

  Future<void> _pickSort(LibraryStore library) async {
    final picked = await showSortMenu<SongSort>(
      context,
      choices: _choices,
      selected: library.songSort,
    );
    // songSort is a plain field, so the sheet closing leaves this page to
    // rebuild the ordering itself.
    if (picked == null || !context.mounted) return;
    library.songSort = picked;
    setState(() {});
  }

  void _play(List<Song> queue, int index) {
    final library = context.read<LibraryStore>();
    context.read<PlayerController>().playQueue(queue, index);
    library.markPlayed(queue[index].id);
    Navigator.of(context).pushNamed(Routes.player);
  }
}

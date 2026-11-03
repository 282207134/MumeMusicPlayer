import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/router.dart';
import '../../app/theme/app_dimens.dart';
import '../../app/theme/app_theme.dart';
import '../../app/widgets/buttons.dart';
import '../../app/widgets/page.dart';
import '../../app/widgets/tiles.dart';
import '../../data/library_store.dart';
import '../../data/models/media.dart';
import '../../data/music_library.dart';
import 'add_to_playlist_screen.dart';

/// `29_add song to playlist` — pick tracks into an existing board from three
/// pools. The tick on the right is the live membership of the playlist.
class AddSongsScreen extends StatefulWidget {
  const AddSongsScreen({super.key, required this.playlistId});

  final String playlistId;

  @override
  State<AddSongsScreen> createState() => _AddSongsScreenState();
}

class _AddSongsScreenState extends State<AddSongsScreen>
    with SingleTickerProviderStateMixin {
  static const _tabs = ['Recent', 'Local', 'Favorites'];

  late final TabController _controller = TabController(
    length: _tabs.length,
    vsync: this,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryStore>();
    final included =
        library.playlistById(widget.playlistId)?.songIds.toSet() ??
        const <String>{};

    return Scaffold(
      appBar: PageTopBar(
        title: 'Add Songs',
        actions: [
          GhostIconButton(
            icon: Icons.search_rounded,
            tooltip: 'Search',
            onPressed: () => Navigator.of(context).pushNamed(Routes.search),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Insets.gapSm),
            child: UnderlineTabs(tabs: _tabs, controller: _controller),
          ),
          Divider(height: 1, color: context.separatorColor),
          Expanded(
            child: TabBarView(
              controller: _controller,
              children: [
                _songList(MusicLibrary.songs.reversed.toList(), included),
                _songList(MusicLibrary.songs, included),
                _songList(library.favorites, included),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _songList(List<Song> songs, Set<String> included) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        Insets.page,
        Insets.gapMd,
        Insets.page,
        Insets.gap2xl,
      ),
      itemCount: songs.length,
      itemBuilder: (context, i) {
        final song = songs[i];
        final added = included.contains(song.id);
        return PlaylistTile(
          title: song.title,
          cover: song.cover,
          subtitle: song.artist,
          trailing: PickMark(
            added: added,
            onTap: () => _toggle(context, song.id, added),
          ),
        );
      },
    );
  }

  void _toggle(BuildContext context, String songId, bool added) {
    final library = context.read<LibraryStore>();
    added
        ? library.removeFromPlaylist(widget.playlistId, songId)
        : library.addToPlaylist(widget.playlistId, songId);
  }
}

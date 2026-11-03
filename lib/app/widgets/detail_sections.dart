import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/library_store.dart';
import '../../data/models/media.dart';
import '../../data/player_controller.dart';
import '../router.dart';
import '../theme/app_dimens.dart';
import 'buttons.dart';
import 'song_option_sheet.dart';
import 'tiles.dart';

/// `Shuffle` + `Play` under the artwork on boards `14` `16` `18`.
class ShufflePlayRow extends StatelessWidget {
  const ShufflePlayRow({super.key, required this.songs});

  final List<Song> songs;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: PrimaryPillButton(
            label: 'Shuffle',
            icon: Icons.shuffle_rounded,
            onPressed: songs.isEmpty ? null : () => _start(context, true),
          ),
        ),
        const SizedBox(width: Insets.gapLg),
        Expanded(
          child: SoftPillButton(
            label: 'Play',
            icon: Icons.play_circle_fill_rounded,
            onPressed: songs.isEmpty ? null : () => _start(context, false),
          ),
        ),
      ],
    );
  }

  void _start(BuildContext context, bool shuffle) =>
      playSongs(context, songs, 0, shuffle: shuffle);
}

/// `Songs` section that folds the tail of the list behind `See All`.
class SongsSection extends StatefulWidget {
  const SongsSection({super.key, required this.songs, this.preview = 3});

  final List<Song> songs;
  final int preview;

  @override
  State<SongsSection> createState() => _SongsSectionState();
}

class _SongsSectionState extends State<SongsSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerController>();
    final more = widget.songs.length > widget.preview;
    final shown = _expanded || !more
        ? widget.songs
        : widget.songs.take(widget.preview).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: 'Songs',
          actionLabel: more ? (_expanded ? 'Show Less' : 'See All') : null,
          onAction: more ? () => setState(() => _expanded = !_expanded) : null,
        ),
        for (var i = 0; i < shown.length; i++)
          SongTile(
            song: shown[i],
            active: player.current?.id == shown[i].id && player.isPlaying,
            onTap: () => playSongs(context, shown, i),
            onPlay: () => playSongs(context, shown, i),
            onMenu: () => showSongOptions(context, shown[i]),
          ),
      ],
    );
  }
}

/// Queue [songs] from [index], remember the play and open the player.
void playSongs(
  BuildContext context,
  List<Song> songs,
  int index, {
  bool shuffle = false,
}) {
  final player = context.read<PlayerController>();
  if (shuffle && !player.shuffle) player.toggleShuffle();
  player.playQueue(songs, index);
  context.read<LibraryStore>().markPlayed(songs[index].id);
  Navigator.of(context).pushNamed(Routes.player);
}

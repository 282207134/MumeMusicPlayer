import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimens.dart';
import '../../app/theme/app_theme.dart';
import '../../app/widgets/app_logo.dart';
import '../../app/widgets/buttons.dart';
import '../../app/widgets/page.dart';
import '../../app/widgets/tiles.dart';
import '../../data/library_store.dart';
import '../../data/music_library.dart';

/// `26_new_playlist` — name the board and pick its artwork. With a
/// [playlistId] the same screen renames an existing playlist.
class NewPlaylistScreen extends StatefulWidget {
  const NewPlaylistScreen({super.key, this.playlistId});

  final String? playlistId;

  @override
  State<NewPlaylistScreen> createState() => _NewPlaylistScreenState();
}

class _NewPlaylistScreenState extends State<NewPlaylistScreen> {
  static const _coverOptions = 12;

  late final TextEditingController _name;
  late final String _cover;

  @override
  void initState() {
    super.initState();
    final existing = widget.playlistId == null
        ? null
        : context.read<LibraryStore>().playlistById(widget.playlistId!);
    _name = TextEditingController(text: existing?.name ?? '');
    _cover = existing?.cover ?? MusicLibrary.cover(0);
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.playlistId != null;

    return MumePage(
      topBar: PageTopBar(title: editing ? 'Edit Playlist' : 'New Playlist'),
      bottomBar: PrimaryPillButton(
        label: editing ? 'Save Changes' : 'Create Playlist',
        onPressed: _name.text.trim().isEmpty ? null : _save,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: Insets.gapLg),
          // The store only renames a playlist, so the artwork rail is a
          // create-time choice; while editing the cover is shown as-is.
          if (editing) ...[
            Center(
                child: CoverArt(
                    asset: _cover, size: 132, radius: Insets.radiusXl)),
            const SizedBox(height: Insets.gapXl),
          ] else ...[
            const SectionHeader(title: 'Playlist Cover', titleSize: 18),
            _coverRail(),
            const SizedBox(height: Insets.gapXl),
          ],
          const SectionHeader(title: 'Playlist Name', titleSize: 18),
          TextField(
            controller: _name,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _save(),
            decoration: const InputDecoration(hintText: 'My Top 50 Songs'),
          ),
        ],
      ),
    );
  }

  Widget _coverRail() {
    return SizedBox(
      height: 74,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _coverOptions,
        separatorBuilder: (_, _) => const SizedBox(width: Insets.gapMd),
        itemBuilder: (context, i) {
          final asset = MusicLibrary.cover(i);
          final selected = asset == _cover;
          return InkWell(
            onTap: () => setState(() => _cover = asset),
            customBorder: const CircleBorder(),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? AppColors.primary : context.separatorColor,
                    width: selected ? 3 : 1,
                  ),
                ),
                child: CoverArt(asset: asset, size: 60, circular: true),
              ),
            ),
          );
        },
      ),
    );
  }

  void _save() {
    final library = context.read<LibraryStore>();
    final id = widget.playlistId;
    if (id != null) {
      library.renamePlaylist(id, _name.text);
      Navigator.of(context).pop();
      return;
    }
    final created = library.createPlaylist(_name.text, cover: _cover);
    Navigator.of(context)
      ..pop()
      ..pushNamed(Routes.playlist, arguments: MediaArgs(created.id));
  }
}

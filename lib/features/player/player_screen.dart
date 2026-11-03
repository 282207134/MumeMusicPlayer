import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimens.dart';
import '../../app/theme/app_theme.dart';
import '../../app/theme/app_typography.dart';
import '../../app/widgets/app_logo.dart';
import '../../app/widgets/buttons.dart';
import '../../app/widgets/page.dart';
import '../../app/widgets/sheets.dart';
import '../../app/widgets/song_option_sheet.dart';
import '../../app/widgets/tiles.dart';
import '../../data/models/media.dart';
import '../../data/music_library.dart';
import '../../data/player_controller.dart';

/// `9_Light_play song` — artwork, transport and a lyrics preview block.
class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerController>();
    final song = player.current;

    return Scaffold(
      appBar: const PageHeaderActions(),
      body: SafeArea(
        top: false,
        child: song == null
            ? const EmptyState(
                title: 'Nothing is playing',
                message: 'Pick a track from Home to start the player.',
                icon: Icons.play_circle_outline_rounded,
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(
                  Insets.page,
                  0,
                  Insets.page,
                  Insets.gap2xl,
                ),
                children: [
                  Center(
                    child: Hero(
                      tag: 'cover-${song.id}',
                      child: CoverArt(
                        asset: song.cover,
                        size: 380,
                        radius: Insets.radiusXl,
                      ),
                    ),
                  ),
                  const SizedBox(height: Insets.gapXl),
                  Text(
                    song.title,
                    textAlign: TextAlign.center,
                    style: AppTypography.heading(
                      AppTypography.h4,
                      color: context.inkPrimary,
                    ),
                  ),
                  const SizedBox(height: Insets.gapSm),
                  Text(
                    song.artist,
                    textAlign: TextAlign.center,
                    style: AppTypography.body(
                      AppTypography.bodyXLarge,
                      color: context.inkMuted,
                    ),
                  ),
                  const SizedBox(height: Insets.gapXl),
                  const SeekBar(),
                  const SizedBox(height: Insets.gapLg),
                  const TransportRow(),
                  const SizedBox(height: Insets.gapLg),
                  const SecondaryControlsRow(),
                  const SizedBox(height: Insets.gapXl),
                  Divider(color: context.separatorColor),
                  LyricsPreview(
                    onExpand: () =>
                        Navigator.of(context).pushNamed(Routes.lyrics),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Orange slider with the elapsed / total read-outs under it.
class SeekBar extends StatelessWidget {
  const SeekBar({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerController>();
    final total = player.duration.inMilliseconds;

    return Column(
      children: [
        Slider(
          value: (player.position.inMilliseconds / (total == 0 ? 1 : total))
              .clamp(0, 1),
          onChanged: total == 0
              ? null
              : (v) => player.seek(Duration(milliseconds: (v * total).round())),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Insets.gapSm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatClock(player.position),
                style: AppTypography.body(
                  AppTypography.bodyLarge,
                  weight: FontWeight.w600,
                  color: context.inkPrimary,
                ),
              ),
              Text(
                player.durationLabel,
                style: AppTypography.body(
                  AppTypography.bodyLarge,
                  weight: FontWeight.w600,
                  color: context.inkMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

extension on PlayerController {
  String get durationLabel => formatClock(duration);
}

/// Previous / −10 / play / +10 / next.
class TransportRow extends StatelessWidget {
  const TransportRow({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerController>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GhostIconButton(
          icon: Icons.skip_previous_rounded,
          size: 30,
          onPressed: player.previous,
        ),
        GhostIconButton(
          icon: Icons.replay_10_rounded,
          size: 30,
          onPressed: () => player.skip(-10),
        ),
        PlayBadge(
          playing: player.isPlaying,
          onPressed: player.toggle,
          size: 68,
        ),
        GhostIconButton(
          icon: Icons.forward_10_rounded,
          size: 30,
          onPressed: () => player.skip(10),
        ),
        GhostIconButton(
          icon: Icons.skip_next_rounded,
          size: 30,
          onPressed: player.next,
        ),
      ],
    );
  }
}

/// Speed / sleep timer / cast / more.
class SecondaryControlsRow extends StatelessWidget {
  const SecondaryControlsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerController>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GhostIconButton(
          icon: Icons.speed_rounded,
          size: 26,
          color: player.speed == 1 ? null : AppColors.primary,
          onPressed: player.cycleSpeed,
          tooltip: 'Speed ${player.speed}x',
        ),
        GhostIconButton(
          icon: Icons.bedtime_outlined,
          size: 26,
          color: player.sleepMinutes == null ? null : AppColors.primary,
          onPressed: () => showSleepTimer(context, player),
        ),
        const GhostIconButton(icon: Icons.cast_connected_outlined, size: 26),
        GhostIconButton(
          icon: Icons.more_horiz_rounded,
          size: 26,
          onPressed: () {
            final song = player.current;
            if (song != null) showSongOptions(context, song);
          },
        ),
      ],
    );
  }
}

void showSleepTimer(BuildContext context, PlayerController player) {
  showMumeSheet(
    context,
    builder: (ctx) => MumeSheet(
      title: 'Sleep Timer',
      children: [
        for (final minutes in const [15, 30, 45, 60, 90])
          OptionTile(
            icon: Icons.alarm_outlined,
            label: '$minutes minutes',
            trailing: player.sleepMinutes == minutes
                ? const Icon(Icons.check_rounded, color: AppColors.primary)
                : null,
            onTap: () {
              player.setSleepMinutes(minutes);
              Navigator.of(ctx).pop();
            },
          ),
        OptionTile(
          icon: Icons.close_rounded,
          label: 'Turn off',
          onTap: () {
            player.setSleepMinutes(null);
            Navigator.of(ctx).pop();
          },
        ),
      ],
    ),
  );
}

/// `10_Light_play song, lyric` — the scrolling lyric block.
class LyricsPreview extends StatelessWidget {
  const LyricsPreview({super.key, this.onExpand, this.lines = 6});

  final VoidCallback? onExpand;
  final int lines;

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerController>();
    final song = player.current;
    if (song == null) return const SizedBox.shrink();
    final lyrics = MusicLibrary.lyricsFor(song);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Column(
          children: [
            if (onExpand != null)
              GhostIconButton(
                icon: Icons.expand_less_rounded,
                size: 26,
                onPressed: onExpand,
                tooltip: 'Expand lyrics',
              ),
            Text(
              'Lyrics',
              style: AppTypography.heading(
                AppTypography.h5,
                color: context.inkPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: Insets.gapLg),
        InkWell(
          onTap: onExpand,
          borderRadius: BorderRadius.circular(Insets.radiusXl),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(Insets.gapXl),
            decoration: BoxDecoration(
              color: context.tintBackground,
              borderRadius: BorderRadius.circular(Insets.radiusXl),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < lyrics.length && i < lines; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Insets.gapMd),
                    child: Text(
                      lyrics[i],
                      style: AppTypography.body(
                        AppTypography.bodyXLarge,
                        weight: FontWeight.w700,
                        color: i <= player.lyricLine
                            ? AppColors.primary
                            : context.inkPrimary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Full-height lyric view.
class LyricsScreen extends StatelessWidget {
  const LyricsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerController>();
    final song = player.current;
    final lyrics = song == null
        ? const <String>[]
        : MusicLibrary.lyricsFor(song);

    return Scaffold(
      appBar: const PageHeaderActions(),
      body: song == null
          ? const EmptyState(
              title: 'Nothing is playing',
              message: 'Start a track to follow along with the words.',
              icon: Icons.lyrics_outlined,
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                Insets.page,
                Insets.gap2xl,
                Insets.page,
                Insets.gap2xl,
              ),
              children: [
                const SeekBar(),
                const SizedBox(height: Insets.gapLg),
                const TransportRow(),
                const SizedBox(height: Insets.gapLg),
                const SecondaryControlsRow(),
                const SizedBox(height: Insets.gapXl),
                Divider(color: context.separatorColor),
                const SizedBox(height: Insets.gapLg),
                Text(
                  'Lyrics',
                  style: AppTypography.heading(
                    AppTypography.h5,
                    color: context.inkPrimary,
                  ),
                ),
                const SizedBox(height: Insets.gapXl),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(Insets.gapXl),
                  decoration: BoxDecoration(
                    color: context.tintBackground,
                    borderRadius: BorderRadius.circular(Insets.radiusXl),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < lyrics.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: Insets.gapLg),
                          child: Text(
                            lyrics[i],
                            style: AppTypography.body(
                              AppTypography.bodyXLarge,
                              weight: FontWeight.w700,
                              color: i <= player.lyricLine
                                  ? AppColors.primary
                                  : context.inkPrimary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

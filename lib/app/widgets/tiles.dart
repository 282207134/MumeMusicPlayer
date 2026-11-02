import 'package:flutter/material.dart';

import '../../data/models/media.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';
import 'app_logo.dart';
import 'buttons.dart';

/// `Recently Played` + `See All` — the section header on Home boards.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.padding = const EdgeInsets.only(bottom: Insets.gapLg),
    this.titleSize,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EdgeInsets padding;
  final double? titleSize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTypography.heading(
                titleSize ?? AppTypography.h5,
                color: context.inkPrimary,
              ),
            ),
          ),
          if (actionLabel != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(actionLabel!),
            ),
        ],
      ),
    );
  }
}

/// `560 songs` on the left, `Ascending ⇅` on the right.
class CountSortBar extends StatelessWidget {
  const CountSortBar({
    super.key,
    required this.count,
    required this.sortLabel,
    this.onSort,
  });

  final String count;
  final String sortLabel;
  final VoidCallback? onSort;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Insets.gapLg),
      child: Row(
        children: [
          Expanded(
            child: Text(
              count,
              style: AppTypography.heading(AppTypography.h5,
                  color: context.inkPrimary),
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(Insets.radiusSm),
            onTap: onSort,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: Insets.gapSm, vertical: Insets.gapSm),
              child: Row(
                children: [
                  Text(
                    sortLabel,
                    style: AppTypography.body(
                      AppTypography.bodyXLarge,
                      weight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: Insets.gapSm),
                  const Icon(Icons.swap_vert_rounded,
                      color: AppColors.primary, size: 22),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Cover + title + `artist | duration` + play badge + overflow menu.
class SongTile extends StatelessWidget {
  const SongTile({
    super.key,
    required this.song,
    this.active = false,
    this.onTap,
    this.onPlay,
    this.onMenu,
    this.trailingText,
    this.showPlayBadge = true,
    this.coverSize = Insets.coverTile,
  });

  final Song song;
  final bool active;
  final VoidCallback? onTap;
  final VoidCallback? onPlay;
  final VoidCallback? onMenu;
  final String? trailingText;
  final bool showPlayBadge;
  final double coverSize;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Insets.gapMd),
        child: Row(
          children: [
            CoverArt(asset: song.cover, size: coverSize),
            const SizedBox(width: Insets.gapLg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.body(
                      AppTypography.bodyXLarge,
                      weight: FontWeight.w700,
                      color: context.inkPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _subtitle(context),
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
            const SizedBox(width: Insets.gapMd),
            if (showPlayBadge)
              PlayBadge(playing: active, onPressed: onPlay)
            else if (active)
              const Icon(Icons.equalizer_rounded,
                  color: AppColors.primary, size: 22),
            if (onMenu != null)
              GhostIconButton(
                icon: Icons.more_vert_rounded,
                onPressed: onMenu,
                size: 22,
                tooltip: 'Options',
              ),
          ],
        ),
      ),
    );
  }

  String _subtitle(BuildContext context) {
    final parts = <String>[
      song.artist,
      trailingText ?? '${song.durationLabel} mins',
    ];
    return parts.join('  |  ');
  }
}

/// Playlist row: artwork, name, `n songs`, optional menu.
class PlaylistTile extends StatelessWidget {
  const PlaylistTile({
    super.key,
    required this.title,
    required this.cover,
    required this.subtitle,
    this.onTap,
    this.onMenu,
    this.trailing,
    this.coverSize = 64,
  });

  final String title;
  final String cover;
  final String subtitle;
  final VoidCallback? onTap;
  final VoidCallback? onMenu;
  final Widget? trailing;
  final double coverSize;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Insets.gapMd),
        child: Row(
          children: [
            CoverArt(asset: cover, size: coverSize, radius: Insets.radiusXl),
            const SizedBox(width: Insets.gapLg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.body(
                      AppTypography.bodyXLarge,
                      weight: FontWeight.w700,
                      color: context.inkPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTypography.body(AppTypography.bodyMedium,
                        color: context.inkMuted),
                  ),
                ],
              ),
            ),
            trailing ??
                (onMenu == null
                    ? const SizedBox.shrink()
                    : GhostIconButton(
                        icon: Icons.more_vert_rounded,
                        onPressed: onMenu,
                        size: 22)),
          ],
        ),
      ),
    );
  }
}

/// Circular artist cell for the Home/Artist grids.
class ArtistCell extends StatelessWidget {
  const ArtistCell({
    super.key,
    required this.name,
    required this.cover,
    this.size = Insets.coverGrid,
    this.onTap,
    this.onMenu,
  });

  final String name;
  final String cover;
  final double size;
  final VoidCallback? onTap;
  final VoidCallback? onMenu;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Insets.radiusLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CoverArt(asset: cover, size: size, circular: true),
          const SizedBox(height: Insets.gapMd),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.body(
              AppTypography.bodyXLarge,
              weight: FontWeight.w700,
              color: context.inkPrimary,
            ),
          ),
          if (onMenu != null)
            Align(
              alignment: Alignment.centerRight,
              child: GhostIconButton(
                icon: Icons.more_horiz_rounded,
                onPressed: onMenu,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }
}

/// Square album cell with title + artist under the artwork.
class AlbumCell extends StatelessWidget {
  const AlbumCell({
    super.key,
    required this.title,
    required this.artist,
    required this.cover,
    this.onTap,
  });

  final String title;
  final String artist;
  final String cover;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Insets.radiusXl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CoverArt(asset: cover, size: double.infinity, radius: Insets.radiusXl),
          const SizedBox(height: Insets.gapMd),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.body(
              AppTypography.bodyLarge,
              weight: FontWeight.w700,
              color: context.inkPrimary,
            ),
          ),
          Text(
            artist,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.body(AppTypography.bodyMedium,
                color: context.inkMuted),
          ),
        ],
      ),
    );
  }
}

/// `→ Play Next` style row inside the option sheets.
class OptionTile extends StatelessWidget {
  const OptionTile({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.destructive = false,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool destructive;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final color =
        destructive ? AppColors.error : (context.inkPrimary);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(width: Insets.gapLg),
            Expanded(
              child: Text(
                label,
                style: AppTypography.body(
                  AppTypography.bodyXLarge,
                  weight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

/// `Dark Mode  ( )` / `Language  English (US)  >` settings row.
class SettingTile extends StatelessWidget {
  const SettingTile({
    super.key,
    required this.icon,
    required this.label,
    this.value,
    this.onTap,
    this.trailing,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? AppColors.error : context.inkPrimary;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Row(
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(width: Insets.gapLg),
            Expanded(
              child: Text(
                label,
                style: AppTypography.body(
                  AppTypography.bodyXLarge,
                  weight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
            if (value != null)
              Padding(
                padding: const EdgeInsets.only(right: Insets.gapSm),
                child: Text(
                  value!,
                  style: AppTypography.body(
                    AppTypography.bodyXLarge,
                    weight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            trailing ??
                Icon(Icons.arrow_forward_ios_rounded,
                    size: 16, color: context.inkSoft),
          ],
        ),
      ),
    );
  }
}

/// Nothing-found illustration + copy, used by search and empty playlists.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.music_off_rounded,
    this.action,
  });

  final String title;
  final String message;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Insets.gap2xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: context.tintBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: AppColors.primary),
            ),
            const SizedBox(height: Insets.gapXl),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.heading(AppTypography.h5,
                  color: context.inkPrimary),
            ),
            const SizedBox(height: Insets.gapMd),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.body(AppTypography.bodyLarge,
                  color: context.inkMuted),
            ),
            if (action != null) ...[
              const SizedBox(height: Insets.gapXl),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

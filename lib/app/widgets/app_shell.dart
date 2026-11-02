import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/player_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';
import 'app_logo.dart';
import 'buttons.dart';

/// The four root destinations shown by the floating bar.
enum ShellTab { home, favorites, playlists, settings }

/// App chrome: page body, the mini player and the floating bottom bar.
class MumeScaffold extends StatelessWidget {
  const MumeScaffold({
    super.key,
    required this.body,
    this.selectedTab,
    this.onTabSelected,
    this.floatingBottom,
    this.showMiniPlayer = true,
  });

  final Widget body;
  final ShellTab? selectedTab;
  final ValueChanged<ShellTab>? onTabSelected;
  final Widget? floatingBottom;
  final bool showMiniPlayer;

  @override
  Widget build(BuildContext context) {
    final hasNav = onTabSelected != null;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned.fill(child: body),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showMiniPlayer && hasNav) const MiniPlayer(),
                ?floatingBottom,
                if (hasNav)
                  MumeBottomNav(
                    selected: selectedTab ?? ShellTab.home,
                    onSelect: onTabSelected!,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Home / Favorites / Playlists / Settings, orange when active.
class MumeBottomNav extends StatelessWidget {
  const MumeBottomNav({super.key, required this.selected, required this.onSelect});

  final ShellTab selected;
  final ValueChanged<ShellTab> onSelect;

  static const _icons = {
    ShellTab.home: Icons.home_rounded,
    ShellTab.favorites: Icons.favorite_outline_rounded,
    ShellTab.playlists: Icons.queue_music_rounded,
    ShellTab.settings: Icons.settings_rounded,
  };

  static const _filled = {
    ShellTab.home: Icons.home,
    ShellTab.favorites: Icons.favorite,
    ShellTab.playlists: Icons.queue_music,
    ShellTab.settings: Icons.settings,
  };

  static const _labels = {
    ShellTab.home: 'Home',
    ShellTab.favorites: 'Favorites',
    ShellTab.playlists: 'Playlists',
    ShellTab.settings: 'Settings',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(Insets.radiusXl)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.4 : 0.07),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: Insets.navBarHeight,
          child: Row(
            children: [
              for (final tab in ShellTab.values)
                Expanded(
                  child: InkWell(
                    onTap: () => onSelect(tab),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          tab == selected ? _filled[tab] : _icons[tab],
                          size: 24,
                          color: tab == selected
                              ? AppColors.primary
                              : context.inkSoft,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _labels[tab]!,
                          style: AppTypography.body(
                            AppTypography.bodySmall,
                            weight: FontWeight.w600,
                            color: tab == selected
                                ? AppColors.primary
                                : context.inkSoft,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Collapsed transport strip above the nav bar (`11_play song overscreen`).
class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerController>();
    final song = player.current;
    if (song == null) return const SizedBox.shrink();

    return Material(
      color: context.cardBackground,
      child: InkWell(
        onTap: () => Navigator.of(context).pushNamed('/player'),
        child: Column(
          children: [
            Divider(height: 1, thickness: 1, color: context.separatorColor),
            SizedBox(
              height: 62,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Insets.page),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        CoverArt(asset: song.cover, size: 44, radius: Insets.radiusMd),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: player.progress,
                              minHeight: 2.5,
                              backgroundColor: Colors.black26,
                              valueColor:
                                  const AlwaysStoppedAnimation(AppColors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: Insets.gapMd),
                    Expanded(
                      child: Text(
                        '${song.title} - ${song.artist}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.body(
                          AppTypography.bodyLarge,
                          weight: FontWeight.w700,
                          color: context.inkPrimary,
                        ),
                      ),
                    ),
                    GhostIconButton(
                      icon: player.isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      size: 26,
                      color: AppColors.primary,
                      onPressed: player.toggle,
                    ),
                    GhostIconButton(
                      icon: Icons.skip_next_rounded,
                      size: 26,
                      color: AppColors.primary,
                      onPressed: player.next,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';

/// Solid orange pill with the kit's soft glow — the primary CTA on every board.
class PrimaryPillButton extends StatelessWidget {
  const PrimaryPillButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.height = 56,
    this.expanded = true,
    this.gradient = AppColors.gradientOrange,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;
  final bool expanded;
  final List<Color> gradient;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return SizedBox(
      height: height,
      width: expanded ? double.infinity : null,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Insets.radiusPill),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: enabled ? gradient : const [AppColors.disabledButton, AppColors.disabledButton],
          ),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(Insets.radiusPill),
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Insets.gapXl),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: AppColors.white, size: 22),
                    const SizedBox(width: Insets.gapMd),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.body(
                        AppTypography.bodyXLarge,
                        weight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Tinted pill — the secondary action next to a primary one (Play vs Shuffle).
class SoftPillButton extends StatelessWidget {
  const SoftPillButton({
    super.key,
    required this.label,
    required this.icon,
    this.onPressed,
    this.height = 56,
    this.color = AppColors.primary,
    this.tint,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final double height;
  final Color color;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Material(
        color: tint ?? context.tintBackground,
        borderRadius: BorderRadius.circular(Insets.radiusPill),
        child: InkWell(
          borderRadius: BorderRadius.circular(Insets.radiusPill),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Insets.gapXl),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: Insets.gapMd),
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.body(
                      AppTypography.bodyXLarge,
                      weight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Thin-stroke circle that holds a header action (search, queue, theme dot).
class OutlinedIconButton extends StatelessWidget {
  const OutlinedIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 46,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = SizedBox(
      width: size,
      height: size,
      child: Material(
        color: Colors.transparent,
        shape: CircleBorder(
          side: BorderSide(color: context.separatorColor, width: 1.4),
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Icon(icon, size: size * 0.46, color: context.inkPrimary),
        ),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}

/// Bare circular icon button used for back arrows and row menus.
class GhostIconButton extends StatelessWidget {
  const GhostIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 26,
    this.color,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final Color? color;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: size, color: color ?? context.inkPrimary),
      style: IconButton.styleFrom(
        minimumSize: const Size(44, 44),
        padding: EdgeInsets.zero,
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}

/// The small filled orange disc on song rows.
class PlayBadge extends StatelessWidget {
  const PlayBadge({
    super.key,
    required this.playing,
    this.onPressed,
    this.size = 40,
  });

  final bool playing;
  final VoidCallback? onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: playing ? 'Pause' : 'Play',
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: AppColors.gradientOrange,
            ),
          ),
          child: Icon(
            playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
            color: AppColors.white,
            size: size * 0.58,
          ),
        ),
      ),
    );
  }
}

/// Underline tab strip used by the Home sections.
class UnderlineTabs extends StatelessWidget {
  const UnderlineTabs({
    super.key,
    required this.tabs,
    required this.controller,
    this.onTap,
  });

  final List<String> tabs;
  final TabController controller;
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: controller,
      onTap: onTap,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      dividerColor: Colors.transparent,
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      labelPadding: const EdgeInsets.symmetric(horizontal: Insets.gapLg),
      labelColor: AppColors.primary,
      unselectedLabelColor: context.inkSoft,
      labelStyle: AppTypography.body(
        AppTypography.bodyXLarge,
        weight: FontWeight.w600,
      ),
      unselectedLabelStyle: AppTypography.body(
        AppTypography.bodyXLarge,
        weight: FontWeight.w600,
      ),
      indicatorColor: AppColors.primary,
      indicatorWeight: 3,
      indicatorPadding: const EdgeInsets.only(bottom: 2),
      tabs: [for (final t in tabs) Tab(text: t, height: 48)],
    );
  }
}

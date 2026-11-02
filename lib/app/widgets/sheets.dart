import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';
import 'app_logo.dart';
import 'buttons.dart';

/// Standard sheet chrome: grab handle, optional header row, scrollable body.
class MumeSheet extends StatelessWidget {
  const MumeSheet({
    super.key,
    required this.children,
    this.title,
    this.header,
    this.maxHeightFactor = 0.86,
  });

  final List<Widget> children;
  final String? title;
  final Widget? header;
  final double maxHeightFactor;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * maxHeightFactor,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: Insets.gapMd),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.separatorColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: Insets.gapLg),
            ?header,
            if (title != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    Insets.page, 0, Insets.page, Insets.gapMd),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title!,
                    style: AppTypography.heading(AppTypography.h5,
                        color: context.inkPrimary),
                  ),
                ),
              ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                    Insets.page, 0, Insets.page, Insets.gapXl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: children,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Sheet header that repeats the song row: artwork, title, meta, heart.
class SongSheetHeader extends StatelessWidget {
  const SongSheetHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.cover,
    this.onFavorite,
    this.favorited = false,
  });

  final String title;
  final String subtitle;
  final String cover;
  final VoidCallback? onFavorite;
  final bool favorited;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Insets.gapLg),
      child: Row(
        children: [
          CoverArt(asset: cover, size: 64, radius: Insets.radiusLg),
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
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body(AppTypography.bodyMedium,
                      color: context.inkMuted),
                ),
              ],
            ),
          ),
          if (onFavorite != null)
            GhostIconButton(
              icon: favorited ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
              color: favorited ? AppColors.primary : null,
              onPressed: onFavorite,
              tooltip: 'Favorite',
            ),
        ],
      ),
    );
  }
}

/// Opens [MumeSheet] with the kit's rounded-top surface.
Future<T?> showMumeSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool isScrollControlled = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    useSafeArea: true,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: builder,
  );
}

/// Two-choice confirmation dialog matching the `41_quit modal` board.
Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Yes',
  String cancelLabel = 'No',
  bool destructive = true,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      child: Padding(
        padding: const EdgeInsets.all(Insets.gapXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.heading(AppTypography.h5,
                  color: ctx.inkPrimary),
            ),
            const SizedBox(height: Insets.gapMd),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.body(AppTypography.bodyLarge,
                  color: ctx.inkMuted),
            ),
            const SizedBox(height: Insets.gapXl),
            PrimaryPillButton(
              label: confirmLabel,
              height: 52,
              gradient:
                  destructive ? const [AppColors.error, AppColors.error] : AppColors.gradientOrange,
              onPressed: () => Navigator.of(ctx).pop(true),
            ),
            const SizedBox(height: Insets.gapMd),
            SoftPillButton(
              label: cancelLabel,
              icon: Icons.close_rounded,
              height: 52,
              color: ctx.inkPrimary,
              onPressed: () => Navigator.of(ctx).pop(false),
            ),
          ],
        ),
      ),
    ),
  );
  return result ?? false;
}

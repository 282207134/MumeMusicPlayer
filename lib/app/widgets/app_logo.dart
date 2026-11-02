import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_typography.dart';

/// The orange beamed-notes mark from the UI Kit's `Logo` component.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 34, this.badge = false});

  final double size;

  /// Splash / walkthrough treatment: white notes on an orange circle.
  final bool badge;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      'assets/images/logo_mark.png',
      width: badge ? size * 0.5 : size,
      height: badge ? size * 0.5 : size,
      fit: BoxFit.contain,
      color: badge ? Colors.white : null,
    );
    if (!badge) return image;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.gradientOrange,
        ),
      ),
      child: Center(child: image),
    );
  }
}

/// `Mume` wordmark next to the logo, as used by every Home/Settings header.
class AppWordmark extends StatelessWidget {
  const AppWordmark({super.key, this.title = 'Mume', this.onSearch});

  final String title;
  final VoidCallback? onSearch;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const AppLogo(size: 32),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: AppTypography.heading(AppTypography.h4,
                color: Theme.of(context).textTheme.bodyLarge?.color),
          ),
        ),
        if (onSearch != null)
          IconButton(
            onPressed: onSearch,
            icon: const Icon(Icons.search_rounded, size: 26),
            tooltip: 'Search',
          ),
      ],
    );
  }
}

/// Rounded artwork used for covers, avatars and tiles.
class CoverArt extends StatelessWidget {
  const CoverArt({
    super.key,
    required this.asset,
    this.size = Insets.coverTile,
    this.radius = Insets.radiusLg,
    this.circular = false,
  });

  final String asset;
  final double size;
  final double radius;
  final bool circular;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(circular ? size : radius),
      child: Image.asset(
        asset,
        width: size,
        height: size,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.medium,
      ),
    );
  }
}

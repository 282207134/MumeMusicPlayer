import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimens.dart';
import '../../app/theme/app_theme.dart';
import '../../app/theme/app_typography.dart';
import '../../app/widgets/app_logo.dart';

/// `1_Light_splash screen` — wordmark centred, dot spinner below.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spinner = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 2000), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(Routes.walkthrough);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _spinner.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Wordmark sits a hair above the optical centre, spinner at 80% height.
          Align(
            alignment: const Alignment(0, -0.06),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppLogo(size: 64, badge: true),
                const SizedBox(width: Insets.gapLg),
                Text(
                  'Mume',
                  style: AppTypography.heading(
                    AppTypography.h1 * 0.75,
                    color: context.inkPrimary,
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: const Alignment(0, 0.6),
            child: AnimatedBuilder(
              animation: _spinner,
              builder: (context, _) => Transform.rotate(
                angle: _spinner.value * math.pi * 2,
                child: const _DotSpinner(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DotSpinner extends StatelessWidget {
  const _DotSpinner();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        children: [
          for (var i = 0; i < 8; i++)
            Positioned.fill(
              child: Transform.rotate(
                angle: i * math.pi / 4,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: 9 - i.toDouble(),
                    height: 9 - i.toDouble(),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withValues(alpha: 1 - i / 9),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

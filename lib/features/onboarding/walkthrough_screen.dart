import 'package:flutter/material.dart';

import '../../app/router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimens.dart';
import '../../app/theme/app_typography.dart';
import '../../app/widgets/buttons.dart';

class _Step {
  const _Step(this.image, this.headline);

  final String image;
  final String headline;
}

/// `2..4_Light_walkthrough` — three onboarding pages on a horizontal pager.
class WalkthroughScreen extends StatefulWidget {
  const WalkthroughScreen({super.key});

  @override
  State<WalkthroughScreen> createState() => _WalkthroughScreenState();
}

class _WalkthroughScreenState extends State<WalkthroughScreen> {
  static const _steps = <_Step>[
    _Step('assets/images/walkthrough_1.png',
        'User friendly mp3 music player for your device'),
    _Step('assets/images/walkthrough_2.png',
        'Find your songs by name, artist, album and more'),
    _Step('assets/images/walkthrough_3.png', 'Listen to the best audio & music with Mume now!'),
  ];

  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isLast => _page == _steps.length - 1;

  void _advance() {
    if (_isLast) {
      Navigator.of(context).pushReplacementNamed(Routes.home);
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.dark1 : AppColors.white,
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: _steps.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (context, i) => _Hero(image: _steps[i].image),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
                Insets.gap2xl, Insets.gap2xl, Insets.gap2xl, Insets.gapXl),
            decoration: BoxDecoration(
              color: isDark ? AppColors.dark2 : AppColors.white,
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(36)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.06),
                  blurRadius: 30,
                  offset: const Offset(0, -10),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  _steps[_page].headline,
                  textAlign: TextAlign.center,
                  style: AppTypography.heading(AppTypography.h2 * 0.85,
                      color: isDark ? AppColors.white : AppColors.grey900),
                ),
                const SizedBox(height: Insets.gapXl),
                _Indicator(count: _steps.length, index: _page),
                const SizedBox(height: Insets.gapXl),
                PrimaryPillButton(
                  label: _isLast ? 'Get Started' : 'Next',
                  onPressed: _advance,
                ),
                const SizedBox(height: Insets.gapSm),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.image});

  final String image;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: constraints.maxHeight * 0.18,
            child: Container(
              width: constraints.maxHeight * 0.72,
              height: constraints.maxHeight * 0.72,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: AppColors.primary),
            ),
          ),
          const Positioned(top: Insets.gapXl, left: 44, child: _Speck(26)),
          const Positioned(top: 72, right: 64, child: _Speck(16)),
          const Positioned(top: 34, left: 150, child: _Speck(11)),
          const Positioned(bottom: 90, left: 26, child: _Speck(9)),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: constraints.maxHeight * 0.94,
            child: Image.asset(image, fit: BoxFit.cover, filterQuality: FilterQuality.medium),
          ),
        ],
      ),
    );
  }
}

class _Speck extends StatelessWidget {
  const _Speck(this.size);

  final double size;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
            shape: BoxShape.circle, color: AppColors.primary),
      );
}

class _Indicator extends StatelessWidget {
  const _Indicator({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    final inactive =
        Theme.of(context).brightness == Brightness.dark ? AppColors.dark3 : AppColors.grey300;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: i == index ? 26 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i == index ? AppColors.primary : inactive,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../app/router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimens.dart';
import '../../app/theme/app_theme.dart';
import '../../app/theme/app_typography.dart';
import '../../app/widgets/buttons.dart';
import '../../app/widgets/page.dart';
import '../../app/widgets/sheets.dart';
import '../../app/widgets/tiles.dart';

/// A purchasable Premium tier. Lives here because the whole premium flow
/// (plan card, payment, review, receipt) renders the same model.
@immutable
class PremiumPlan {
  const PremiumPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.tax,
    required this.period,
    required this.months,
    required this.gradient,
    required this.benefits,
  });

  final String id;
  final String name;
  final double price;
  final double tax;
  final String period;

  /// Billing length in calendar months, used to project the renewal date.
  final int months;
  final List<Color> gradient;
  final List<String> benefits;

  String get priceLabel => '\$${price.toStringAsFixed(2)}';
  String get taxLabel => '\$${tax.toStringAsFixed(2)}';
  String get totalLabel => '\$${(price + tax).toStringAsFixed(2)}';
}

abstract final class PremiumPlans {
  static const _benefits = <String>[
    'Listening with better audio quality',
    'Listening without restrictions & ads',
    'Unlimited skips & shuffles play',
  ];

  static const monthly = PremiumPlan(
    id: 'monthly',
    name: 'Premium Monthly',
    price: 9.99,
    tax: 1.99,
    period: '/month',
    months: 1,
    gradient: AppColors.gradientOrange,
    benefits: _benefits,
  );

  static const quarterly = PremiumPlan(
    id: 'quarterly',
    name: 'Premium Quarterly',
    price: 19.99,
    tax: 3.99,
    period: '/3 months',
    months: 3,
    gradient: AppColors.gradientPurple,
    benefits: _benefits,
  );

  static const yearly = PremiumPlan(
    id: 'yearly',
    name: 'Premium Yearly',
    price: 29.99,
    tax: 5.99,
    period: '/year',
    months: 12,
    gradient: AppColors.gradientRed,
    benefits: _benefits,
  );

  static const all = <PremiumPlan>[monthly, quarterly, yearly];

  static PremiumPlan byId(String? id) =>
      all.firstWhere((plan) => plan.id == id, orElse: () => monthly);
}

/// Gradient pricing card, reused by the review board as a plain summary.
class PremiumPlanCard extends StatelessWidget {
  const PremiumPlanCard({
    super.key,
    required this.plan,
    this.selected = false,
    this.onTap,
  });

  final PremiumPlan plan;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Insets.gapLg),
      child: AnimatedScale(
        scale: selected ? 1.02 : 1,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        child: Container(
          padding: EdgeInsets.all(selected ? 3 : 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(31),
            color: selected ? AppColors.primary : Colors.transparent,
            boxShadow: [
              BoxShadow(
                color: plan.gradient.last.withValues(
                  alpha: selected ? 0.45 : 0.28,
                ),
                blurRadius: selected ? 30 : 20,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Material(
            type: MaterialType.transparency,
            borderRadius: BorderRadius.circular(28),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: Ink(
                padding: const EdgeInsets.all(Insets.gapXl),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: plan.gradient,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.workspace_premium_rounded,
                      size: 46,
                      color: AppColors.white,
                    ),
                    const SizedBox(height: Insets.gapLg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          plan.priceLabel,
                          style: AppTypography.heading(
                            AppTypography.h3,
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(width: Insets.gapSm),
                        Flexible(
                          child: Text(
                            plan.period,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.body(
                              AppTypography.bodyLarge,
                              weight: FontWeight.w600,
                              color: AppColors.white.withValues(alpha: 0.75),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Insets.gapXl),
                    Container(
                      height: 1,
                      color: AppColors.white.withValues(alpha: 0.35),
                    ),
                    const SizedBox(height: Insets.gapMd),
                    for (final benefit in plan.benefits)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: Insets.gapSm,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_rounded,
                              size: 22,
                              color: AppColors.white,
                            ),
                            const SizedBox(width: Insets.gapLg),
                            Expanded(
                              child: Text(
                                benefit,
                                style: AppTypography.body(
                                  AppTypography.bodyXLarge,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// `31_Subscribe Premium` — pick a tier, then hand off to the payment board.
class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  static const _subtitle =
      'Enjoy listening songs with better audio quality, without restrictions, and without ads.';

  PremiumPlan _selected = PremiumPlans.monthly;

  void _choose(PremiumPlan plan) => setState(() => _selected = plan);

  void _subscribe() =>
      Navigator.of(context)
          .pushNamed(Routes.paymentMethod, arguments: _selected.id);

  Future<void> _restore() => showMumeSheet<void>(
    context,
    builder: (ctx) => MumeSheet(
      title: 'Restore purchase',
      children: [
        Text(
          'Premium subscriptions are linked to the Google account signed in on this device.',
          style: AppTypography.body(
            AppTypography.bodyLarge,
            color: ctx.inkMuted,
          ),
        ),
        const SizedBox(height: Insets.gapLg),
        Container(
          padding: const EdgeInsets.all(Insets.gapLg),
          decoration: BoxDecoration(
            color: ctx.tintBackground,
            borderRadius: BorderRadius.circular(Insets.radiusLg),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.account_circle_rounded,
                size: 40,
                color: AppColors.primary,
              ),
              const SizedBox(width: Insets.gapLg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'andrew.ainsley@gmail.com',
                      style: AppTypography.body(
                        AppTypography.bodyXLarge,
                        weight: FontWeight.w600,
                        color: ctx.inkPrimary,
                      ),
                    ),
                    Text(
                      'No active Premium subscription found',
                      style: AppTypography.body(
                        AppTypography.bodyMedium,
                        color: ctx.inkMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        OptionTile(
          icon: Icons.close_rounded,
          label: 'Close',
          onTap: () => Navigator.of(ctx).pop(),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return MumePage(
      topBar: const PageTopBar(),
      bottomBar: Column(
        children: [
          PrimaryPillButton(label: 'Subscribe Now', onPressed: _subscribe),
          const SizedBox(height: Insets.gapMd),
          Text(
            'Recurring billing, cancel anytime.',
            style: AppTypography.body(
              AppTypography.bodyMedium,
              color: context.inkSoft,
            ),
          ),
          TextButton(
            onPressed: _restore,
            child: const Text('Restore purchase'),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Subscribe to Premium',
            textAlign: TextAlign.center,
            style: AppTypography.heading(
              AppTypography.h3,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: Insets.gapMd),
          Text(
            _subtitle,
            textAlign: TextAlign.center,
            style: AppTypography.body(
              AppTypography.bodyXLarge,
              color: context.inkMuted,
            ),
          ),
          const SizedBox(height: Insets.gap2xl),
          for (final plan in PremiumPlans.all)
            PremiumPlanCard(
              plan: plan,
              selected: plan.id == _selected.id,
              onTap: () => _choose(plan),
            ),
        ],
      ),
    );
  }
}

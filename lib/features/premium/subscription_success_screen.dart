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
import 'payment_method_screen.dart';
import 'premium_screen.dart';
import 'review_summary_screen.dart';

/// `36_Subscription success` — the paid terminal state of the premium flow.
class SubscriptionSuccessScreen extends StatelessWidget {
  const SubscriptionSuccessScreen({super.key});

  static CheckoutReceipt _receiptFrom(Object? args) {
    if (args is CheckoutReceipt) return args;
    return CheckoutReceipt(
      selection: const PaymentSelection(
        planId: 'monthly',
        kind: PaymentMethodKind.googlePay,
      ),
      paid: PremiumPlans.monthly.price + PremiumPlans.monthly.tax,
      orderedOn: DateTime.now(),
    );
  }

  static DateTime _renewsOn(CheckoutReceipt receipt) {
    final plan = receipt.plan;
    final now = receipt.orderedOn;
    return DateTime(now.year, now.month + plan.months, now.day);
  }

  void _goHome(BuildContext context) => Navigator.of(context)
      .pushNamedAndRemoveUntil(Routes.home, (route) => false);

  Future<void> _showReceipt(BuildContext context, CheckoutReceipt receipt) {
    return showMumeSheet<void>(
      context,
      builder: (ctx) => MumeSheet(
        title: 'Receipt',
        children: [
          _line(ctx, 'Order', receipt.reference),
          _line(ctx, 'Plan', receipt.plan.name),
          _line(ctx, 'Billed to', receipt.selection.displayLabel),
          _line(ctx, 'Ordered on', formatCheckoutDate(receipt.orderedOn)),
          if (receipt.promoCode != null)
            _line(ctx, 'Promo', receipt.promoCode!),
          _line(ctx, 'Paid today', receipt.paidLabel,
              valueColor: AppColors.primary),
          OptionTile(
            icon: Icons.close_rounded,
            label: 'Close',
            onTap: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }

  static Widget _line(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Insets.gapSm),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTypography.body(AppTypography.bodyXLarge,
                  color: context.inkMuted),
            ),
          ),
          Text(
            value,
            style: AppTypography.body(
              AppTypography.bodyXLarge,
              weight: FontWeight.w700,
              color: valueColor ?? context.inkPrimary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final receipt = _receiptFrom(ModalRoute.of(context)?.settings.arguments);
    final plan = receipt.plan;

    return MumePage(
      bottomBar: Column(
        children: [
          PrimaryPillButton(
            label: 'Enjoy Premium',
            onPressed: () => _goHome(context),
          ),
          const SizedBox(height: Insets.gapMd),
          SizedBox(
            width: double.infinity,
            child: SoftPillButton(
              label: 'View Receipt',
              icon: Icons.receipt_long_rounded,
              color: context.inkPrimary,
              onPressed: () => _showReceipt(context, receipt),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: Insets.gap2xl),
          const _SuccessBadge(),
          const SizedBox(height: Insets.gapXl),
          Text(
            'Subscription Successful!',
            textAlign: TextAlign.center,
            style: AppTypography.heading(AppTypography.h3,
                color: context.inkPrimary),
          ),
          const SizedBox(height: Insets.gapMd),
          Text(
            'Premium is now unlocked on this device.\nEnjoy ad-free listening in the best audio quality.',
            textAlign: TextAlign.center,
            style: AppTypography.body(AppTypography.bodyXLarge,
                color: context.inkMuted),
          ),
          const SizedBox(height: Insets.gap2xl),
          Container(
            padding: const EdgeInsets.all(Insets.gapXl),
            decoration: BoxDecoration(
              color: context.tintBackground,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      plan.priceLabel,
                      style: AppTypography.heading(AppTypography.h2,
                          color: AppColors.primary),
                    ),
                    const SizedBox(width: Insets.gapSm),
                    Flexible(
                      child: Text(
                        plan.period,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.body(
                          AppTypography.bodyXLarge,
                          weight: FontWeight.w600,
                          color: context.inkMuted,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Insets.gapLg),
                Divider(color: context.separatorColor, height: 1),
                _line(context, 'Plan', plan.name),
                _line(
                  context,
                  'Renews on',
                  formatCheckoutDate(_renewsOn(receipt)),
                ),
                _line(context, 'Paid today', receipt.paidLabel),
              ],
            ),
          ),
          const SizedBox(height: Insets.gapXl),
        ],
      ),
    );
  }
}

/// Green gradient disc, white check and the confetti specks from board 36.
class _SuccessBadge extends StatelessWidget {
  const _SuccessBadge();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 232,
      height: 196,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 168,
            height: 168,
            decoration: const BoxDecoration(
                shape: BoxShape.circle, color: AppColors.bgGreen),
          ),
          Container(
            width: 124,
            height: 124,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppColors.gradientGreen,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gradientGreen.last.withValues(alpha: 0.4),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_rounded, size: 62, color: AppColors.white),
          const Positioned(top: 18, left: 34, child: _Speck(14, AppColors.primary)),
          const Positioned(top: 40, right: 26, child: _Speck(10, AppColors.success)),
          const Positioned(bottom: 40, left: 20, child: _Speck(9, AppColors.success)),
          const Positioned(bottom: 16, right: 44, child: _Speck(13, AppColors.primary)),
          const Positioned(top: 4, right: 84, child: _Speck(6, AppColors.secondary)),
        ],
      ),
    );
  }
}

class _Speck extends StatelessWidget {
  const _Speck(this.size, this.color);

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );
}

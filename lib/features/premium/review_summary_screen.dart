import 'package:flutter/material.dart';

import '../../app/router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimens.dart';
import '../../app/theme/app_theme.dart';
import '../../app/theme/app_typography.dart';
import '../../app/widgets/buttons.dart';
import '../../app/widgets/page.dart';
import '../../app/widgets/tiles.dart';
import 'payment_method_screen.dart';
import 'premium_screen.dart';

/// `Mon 12 Jan 2026` style stamp, shared by the review and success boards.
String formatCheckoutDate(DateTime date) {
  const months = <String>[
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', // cspell: disable-line
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec', // cspell: disable-line
  ];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}

/// Everything the success board needs to print a receipt.
@immutable
class CheckoutReceipt {
  const CheckoutReceipt({
    required this.selection,
    required this.paid,
    required this.orderedOn,
    this.promoCode,
  });

  final PaymentSelection selection;
  final double paid;
  final DateTime orderedOn;
  final String? promoCode;

  PremiumPlan get plan => selection.plan;
  String get paidLabel => '\$${paid.toStringAsFixed(2)}';
  String get reference => 'MUME-${orderedOn.millisecondsSinceEpoch % 1000000}';
}

/// `35_Review Summary` — order breakdown, payment swap and promo code.
class ReviewSummaryScreen extends StatefulWidget {
  const ReviewSummaryScreen({super.key});

  @override
  State<ReviewSummaryScreen> createState() => _ReviewSummaryScreenState();
}

class _ReviewSummaryScreenState extends State<ReviewSummaryScreen> {
  static const _promoCode = 'MUME10';

  final _promo = TextEditingController();
  PaymentSelection _selection = const PaymentSelection(
    planId: 'monthly',
    kind: PaymentMethodKind.googlePay,
  );
  String? _appliedCode;
  String? _promoError;
  bool _argsRead = false;

  @override
  void dispose() {
    _promo.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsRead) return;
    _argsRead = true;
    final incoming = ModalRoute.of(context)?.settings.arguments;
    if (incoming is PaymentSelection) _selection = incoming;
  }

  double get _discount =>
      _appliedCode == null ? 0 : _selection.plan.price * 0.1;

  double get _total => _selection.plan.price + _selection.plan.tax - _discount;

  void _applyPromo() {
    final code = _promo.text.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() => _promoError = 'Enter a promo code first.');
      return;
    }
    setState(() {
      _appliedCode = code == _promoCode ? code : null;
      _promoError = code == _promoCode ? null : '"$code" is not valid.';
    });
  }

  Future<void> _changePayment() async {
    final result = await Navigator.of(context)
        .pushNamed(Routes.paymentMethod, arguments: _selection);
    if (result is PaymentSelection && mounted) {
      setState(() => _selection = result);
    }
  }

  void _pay() {
    Navigator.of(context).pushNamed(
      Routes.subscriptionDone,
      arguments: CheckoutReceipt(
        selection: _selection,
        paid: _total,
        orderedOn: DateTime.now(),
        promoCode: _appliedCode,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final plan = _selection.plan;
    final discount = _discount;

    return MumePage(
      topBar: const PageTopBar(title: 'Review Summary'),
      bottomBar: Column(
        children: [
          PrimaryPillButton(label: 'Confirm & Pay', onPressed: _pay),
          const SizedBox(height: Insets.gapMd),
          Text(
            'You will be charged \$${_total.toStringAsFixed(2)} today.',
            style: AppTypography.body(
              AppTypography.bodyMedium,
              color: context.inkSoft,
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PremiumPlanCard(plan: plan),
          const SizedBox(height: Insets.gapMd),
          const SectionHeader(
            title: 'Order Summary',
            padding: EdgeInsets.only(bottom: Insets.gapMd),
          ),
          _Panel(
            children: [
              _SummaryRow(label: 'Plan', value: plan.name),
              _SummaryRow(label: 'Amount', value: plan.priceLabel),
              _SummaryRow(label: 'Tax', value: plan.taxLabel),
              if (discount > 0)
                _SummaryRow(
                  label: 'Promo (${_appliedCode!})',
                  value: '-\$${discount.toStringAsFixed(2)}',
                  valueColor: AppColors.success,
                ),
              const Divider(height: Insets.gapXl),
              _SummaryRow(
                label: 'Total',
                value: '\$${_total.toStringAsFixed(2)}',
                emphasize: true,
              ),
            ],
          ),
          const SizedBox(height: Insets.gapXl),
          const SectionHeader(
            title: 'Payment',
            padding: EdgeInsets.only(bottom: Insets.gapMd),
          ),
          _Panel(
            padding: const EdgeInsets.symmetric(
              horizontal: Insets.gapLg,
              vertical: Insets.gapSm,
            ),
            children: [
              Row(
                children: [
                  PaymentMethodMark(
                    kind: _selection.kind,
                    card: _selection.card,
                  ),
                  const SizedBox(width: Insets.gapLg),
                  Expanded(
                    child: Text(
                      _selection.displayLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.body(
                        AppTypography.bodyXLarge,
                        weight: FontWeight.w700,
                        color: context.inkPrimary,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _changePayment,
                    child: const Text('Change'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: Insets.gapXl),
          const SectionHeader(
            title: 'Promo Code',
            padding: EdgeInsets.only(bottom: Insets.gapMd),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _promo,
                  textCapitalization: TextCapitalization.characters,
                  style: AppTypography.body(
                    AppTypography.bodyLarge,
                    weight: FontWeight.w600,
                    color: context.inkPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter code',
                    errorText: _promoError,
                  ),
                ),
              ),
              const SizedBox(width: Insets.gapMd),
              // The pill buttons lay their label out with a flex Row, so they
              // need a bounded width next to the expanded text field.
              SizedBox(
                width: 150,
                child: _appliedCode == null
                    ? PrimaryPillButton(
                        label: 'Apply',
                        height: 54,
                        onPressed: _applyPromo,
                      )
                    : SoftPillButton(
                        label: 'Remove',
                        icon: Icons.remove_circle_outline_rounded,
                        height: 54,
                        color: AppColors.success,
                        onPressed: () => setState(() {
                          _appliedCode = null;
                          _promoError = null;
                          _promo.clear();
                        }),
                      ),
              ),
            ],
          ),
          const SizedBox(height: Insets.gapMd),
          Text(
            'Try $_promoCode for 10% off your first billing term.',
            style: AppTypography.body(
              AppTypography.bodySmall,
              color: context.inkSoft,
            ),
          ),
          const SizedBox(height: Insets.gap2xl),
        ],
      ),
    );
  }
}

/// Rounded surface that groups summary rows — same shell as the payment rows.
class _Panel extends StatelessWidget {
  const _Panel({
    required this.children,
    this.padding = const EdgeInsets.symmetric(
      horizontal: Insets.gapXl,
      vertical: Insets.gapLg,
    ),
  });

  final List<Widget> children;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.separatorColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasize = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool emphasize;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Insets.gapSm),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTypography.body(
                AppTypography.bodyXLarge,
                weight: emphasize ? FontWeight.w700 : FontWeight.w400,
                color: emphasize ? context.inkPrimary : context.inkMuted,
              ),
            ),
          ),
          Text(
            value,
            style: AppTypography.body(
              AppTypography.bodyXLarge,
              weight: emphasize ? FontWeight.w700 : FontWeight.w600,
              color: valueColor ?? context.inkPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

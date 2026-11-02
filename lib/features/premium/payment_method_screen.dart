import 'package:flutter/material.dart';

import '../../app/router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimens.dart';
import '../../app/theme/app_theme.dart';
import '../../app/theme/app_typography.dart';
import '../../app/widgets/buttons.dart';
import '../../app/widgets/page.dart';
import 'card_form_screen.dart';
import 'premium_screen.dart';

enum PaymentMethodKind { googlePay, paypal, card }

extension PaymentMethodKindX on PaymentMethodKind {
  String get label => switch (this) {
        PaymentMethodKind.googlePay => 'Google Pay',
        PaymentMethodKind.paypal => 'PayPal',
        PaymentMethodKind.card => 'Debit or Credit Card',
      };

  IconData get icon => switch (this) {
        PaymentMethodKind.googlePay => Icons.g_mobiledata_rounded,
        PaymentMethodKind.paypal => Icons.paypal,
        PaymentMethodKind.card => Icons.credit_card_rounded,
      };

  Color get tint => switch (this) {
        PaymentMethodKind.googlePay => AppColors.grey100,
        PaymentMethodKind.paypal => AppColors.bgBlue,
        PaymentMethodKind.card => AppColors.bgOrange,
      };

  Color get markColor => switch (this) {
        PaymentMethodKind.googlePay => AppColors.grey800,
        PaymentMethodKind.paypal => AppColors.info,
        PaymentMethodKind.card => AppColors.primary,
      };
}

/// What the shopper picked on this board; travels along the rest of the flow.
@immutable
class PaymentSelection {
  const PaymentSelection({required this.planId, required this.kind, this.card});

  final String planId;
  final PaymentMethodKind kind;
  final BankCard? card;

  PremiumPlan get plan => PremiumPlans.byId(planId);

  String get displayLabel => card?.masked ?? kind.label;
}

/// Round badge in front of every payment row; reused by the review board.
class PaymentMethodMark extends StatelessWidget {
  const PaymentMethodMark({
    super.key,
    required this.kind,
    this.card,
    this.size = 44,
  });

  final PaymentMethodKind kind;
  final BankCard? card;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (card != null) {
      return SizedBox(
        width: size,
        child: Center(child: CardBrandMark(brand: card!.brand, size: size * 0.86)),
      );
    }
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: kind.tint,
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      child: Icon(kind.icon, size: size * 0.52, color: kind.markColor),
    );
  }
}

/// `32/34_Select payment method` — 34 is this same board with a card saved.
class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({super.key});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  final List<BankCard> _cards = [];
  PaymentMethodKind _kind = PaymentMethodKind.googlePay;
  int? _cardIndex;
  String _planId = PremiumPlans.monthly.id;

  /// True when review-summary pushed us, so Continue pops the choice back.
  bool _editing = false;
  bool _argsRead = false;

  BankCard? get _card =>
      _kind == PaymentMethodKind.card && _cardIndex != null && _cardIndex! < _cards.length
          ? _cards[_cardIndex!]
          : null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsRead) return;
    _argsRead = true;
    switch (ModalRoute.of(context)?.settings.arguments) {
      case final PaymentSelection incoming:
        _editing = true;
        _planId = incoming.planId;
        _kind = incoming.kind;
        if (incoming.card != null) {
          _cards.add(incoming.card!);
          _cardIndex = 0;
        }
      case final String planId:
        _planId = planId;
      default:
        break;
    }
  }

  Future<BankCard?> _addCard() async {
    debugPrint('DEBUG addCard pushing ${Routes.cardForm}');
    final result = await Navigator.of(context).pushNamed(Routes.cardForm);
    debugPrint('DEBUG addCard popped with $result');
    final card = result is BankCard ? result : null;
    if (card != null && mounted) {
      setState(() {
        _cards.add(card);
        _cardIndex = _cards.length - 1;
        _kind = PaymentMethodKind.card;
      });
    }
    return card;
  }

  Future<void> _continue() async {
    if (_kind == PaymentMethodKind.card && _card == null) {
      final added = await _addCard();
      if (added == null || !mounted) return;
    }
    final selection = PaymentSelection(planId: _planId, kind: _kind, card: _card);
    if (_editing) {
      Navigator.of(context).pop(selection);
    } else {
      Navigator.of(context).pushNamed(Routes.reviewSummary, arguments: selection);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MumePage(
      topBar: const PageTopBar(title: 'Select Payment Method'),
      bottomBar: PrimaryPillButton(label: 'Continue', onPressed: _continue),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Select the payment method you want to use.',
            style: AppTypography.body(AppTypography.bodyLarge,
                color: context.inkMuted),
          ),
          const SizedBox(height: Insets.gapXl),
          for (final kind in PaymentMethodKind.values) ...[
            _OptionRow(
              title: kind.label,
              selected: _kind == kind && (kind != PaymentMethodKind.card || _card == null),
              leading: PaymentMethodMark(kind: kind),
              onTap: () => setState(() => _kind = kind),
            ),
            if (kind == PaymentMethodKind.card)
              for (var i = 0; i < _cards.length; i++)
                if (_kind == PaymentMethodKind.card)
                  _OptionRow(
                    title: _cards[i].masked,
                    selected: _cardIndex == i,
                    leading: PaymentMethodMark(kind: kind, card: _cards[i]),
                    onTap: () => setState(() => _cardIndex = i),
                  ),
          ],
          const SizedBox(height: Insets.gapSm),
          SoftPillButton(
            label: 'Add New Card',
            icon: Icons.add_rounded,
            onPressed: _addCard,
          ),
          const SizedBox(height: Insets.gapXl),
        ],
      ),
    );
  }
}

/// White card row with a brand mark, a label and the orange radio.
class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.title,
    required this.selected,
    required this.leading,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final Widget leading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Insets.gapLg),
      child: Material(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(Insets.gapLg),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected ? AppColors.primary : context.separatorColor,
                width: selected ? 1.6 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                leading,
                const SizedBox(width: Insets.gapLg),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.body(
                      AppTypography.bodyXLarge,
                      weight: FontWeight.w700,
                      color: context.inkPrimary,
                    ),
                  ),
                ),
                _Radio(selected: selected),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Radio extends StatelessWidget {
  const _Radio({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColors.primary : context.inkSoft,
          width: 2,
        ),
      ),
      child: AnimatedScale(
        scale: selected ? 1 : 0,
        duration: const Duration(milliseconds: 160),
        child: Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(
              shape: BoxShape.circle, color: AppColors.primary),
        ),
      ),
    );
  }
}

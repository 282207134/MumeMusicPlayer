import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimens.dart';
import '../../app/theme/app_theme.dart';
import '../../app/theme/app_typography.dart';
import '../../app/widgets/buttons.dart';
import '../../app/widgets/page.dart';

enum CardBrand { visa, mastercard }

/// A card saved during this checkout session. Only the last four digits ever
/// leave the form, mirroring how a real tokenised card would behave.
@immutable
class BankCard {
  const BankCard({
    required this.holder,
    required this.number,
    required this.expiry,
  });

  final String holder;

  /// Digits only, 16 characters.
  final String number;

  /// `MM/YY`.
  final String expiry;

  CardBrand get brand => brandOf(number);

  static CardBrand brandOf(String digits) =>
      digits.startsWith('4') ? CardBrand.visa : CardBrand.mastercard;

  String get last4 => number.length <= 4 ? number : number.substring(number.length - 4);

  String get masked => '•••• •••• •••• $last4';

  static String grouped(String digits) {
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  /// Four 4-char groups, empty cells filled with bullets, for the card mock.
  static String printed(String digits) {
    final groups = <String>[];
    for (var i = 0; i < 16; i += 4) {
      final chunk = i >= digits.length
          ? ''
          : digits.substring(i, (i + 4) > digits.length ? digits.length : i + 4);
      groups.add(chunk.padRight(4, '•'));
    }
    return groups.join(' ');
  }
}

/// Two-circle / wordmark brand badge drawn in code — the kit ships no logos.
class CardBrandMark extends StatelessWidget {
  const CardBrandMark({super.key, required this.brand, this.size = 44});

  final CardBrand brand;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (brand == CardBrand.visa) {
      return Container(
        width: size,
        height: size * 0.62,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.info,
          borderRadius: BorderRadius.circular(Insets.radiusSm),
        ),
        child: Text(
          'VISA',
          style: AppTypography.body(
            AppTypography.bodyMedium,
            weight: FontWeight.w700,
            color: AppColors.white,
          ).copyWith(letterSpacing: 1.2),
        ),
      );
    }
    final circle = size * 0.52;
    return SizedBox(
      width: size,
      height: circle,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            child: Container(
              width: circle,
              height: circle,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: AppColors.red),
            ),
          ),
          Positioned(
            right: 0,
            child: Container(
              width: circle,
              height: circle,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.amber.withValues(alpha: 0.88),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// `33_Add New Card` — live-previewing card form; pops a [BankCard].
class CardFormScreen extends StatefulWidget {
  const CardFormScreen({super.key});

  @override
  State<CardFormScreen> createState() => _CardFormScreenState();
}

class _CardFormScreenState extends State<CardFormScreen> {
  static final _digitsOnly = FilteringTextInputFormatter.digitsOnly;
  static final _nameOnly = FilteringTextInputFormatter.allow(RegExp(r"[A-Za-z .'-]"));

  final _number = TextEditingController();
  final _expiry = TextEditingController();
  final _cvv = TextEditingController();
  final _holder = TextEditingController();

  @override
  void initState() {
    super.initState();
    // The card mock mirrors the form live, so every keystroke repaints.
    for (final controller in [_number, _expiry, _cvv, _holder]) {
      controller.addListener(_refresh);
    }
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    for (final controller in [_number, _expiry, _cvv, _holder]) {
      controller.removeListener(_refresh);
    }
    _number.dispose();
    _expiry.dispose();
    _cvv.dispose();
    _holder.dispose();
    super.dispose();
  }

  String get _numberDigits => _number.text.replaceAll(RegExp(r'\D'), '');

  bool get _numberValid => _numberDigits.length == 16;

  bool get _expiryValid {
    final match = RegExp(r'^(\d{2})/(\d{2})$').firstMatch(_expiry.text);
    if (match == null) return false;
    final month = int.parse(match.group(1)!);
    final year = int.parse(match.group(2)!);
    if (month < 1 || month > 12) return false;
    final now = DateTime.now();
    if (year < now.year % 100) return false;
    if (year == now.year % 100 && month < now.month) return false;
    return true;
  }

  bool get _cvvValid => _cvv.text.length == 3;

  bool get _holderValid => _holder.text.trim().length >= 3;

  bool get _valid => _numberValid && _expiryValid && _cvvValid && _holderValid;

  void _save() {
    if (!_valid) return;
    Navigator.of(context).pop(BankCard(
      holder: _holder.text.trim(),
      number: _numberDigits,
      expiry: _expiry.text,
    ));
  }

  @override
  Widget build(BuildContext context) {
    // MumePage keeps `resizeToAvoidBottomInset: false`, so the keyboard height
    // has to be read from this context (above the Scaffold) and pushed back
    // into the bottom bar padding.
    final keyboardInset =
        (MediaQuery.viewInsetsOf(context).bottom - Insets.gapLg).clamp(0.0, 400.0);

    return MumePage(
      topBar: PageTopBar(
        title: 'Add New Card',
        actions: [
          GhostIconButton(
            icon: Icons.close_rounded,
            tooltip: 'Close',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      bottomBar: AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(bottom: keyboardInset),
        child: PrimaryPillButton(
          label: 'Save Card',
          onPressed: _valid ? _save : null,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CardPreview(
            number: _numberDigits,
            holder: _holder.text.trim(),
            expiry: _expiry.text,
          ),
          const SizedBox(height: Insets.gap2xl),
          _Field(
            label: 'Card Number',
            controller: _number,
            hint: '1234 5678 9012 3456',
            keyboardType: TextInputType.number,
            inputFormatters: [
              _digitsOnly,
              LengthLimitingTextInputFormatter(16),
              _GroupOfFour(),
            ],
            error: _number.text.isEmpty || _numberValid
                ? null
                : 'A card number has 16 digits',
          ),
          const SizedBox(height: Insets.gapLg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: _Field(
                  label: 'Expiry Date',
                  controller: _expiry,
                  hint: 'MM/YY',
                  keyboardType: TextInputType.number,
                  inputFormatters: [_ExpiryFormatter()],
                  error: _expiry.text.isEmpty || _expiryValid
                      ? null
                      : 'Use a future MM/YY date',
                ),
              ),
              const SizedBox(width: Insets.gapLg),
              Expanded(
                flex: 2,
                child: _Field(
                  label: 'CVV',
                  controller: _cvv,
                  hint: '123',
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  inputFormatters: [_digitsOnly, LengthLimitingTextInputFormatter(3)],
                  error: _cvv.text.isEmpty || _cvvValid
                      ? null
                      : 'CVV has 3 digits',
                ),
              ),
            ],
          ),
          const SizedBox(height: Insets.gapLg),
          _Field(
            label: 'Card Holder Name',
            controller: _holder,
            hint: 'Andrew Ainsley',
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.words,
            inputFormatters: [_nameOnly, LengthLimitingTextInputFormatter(24)],
            error: _holder.text.isEmpty || _holderValid
                ? null
                : 'Enter the name printed on the card',
          ),
          const SizedBox(height: Insets.gapXl),
        ],
      ),
    );
  }
}

/// Orange-to-purple card mock that mirrors the form as it is typed.
class _CardPreview extends StatelessWidget {
  const _CardPreview({
    required this.number,
    required this.holder,
    required this.expiry,
  });

  final String number;
  final String holder;
  final String expiry;

  @override
  Widget build(BuildContext context) {
    const dimmed = Color(0xB3FFFFFF);
    return AspectRatio(
      aspectRatio: 1.62,
      child: Container(
        padding: const EdgeInsets.all(Insets.gapXl),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Insets.radiusXl),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.gradientOrange.first,
              AppColors.gradientOrange.last,
              AppColors.gradientPurple.last,
            ],
            stops: const [0, 0.45, 1],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mume Card',
                  style: AppTypography.body(
                    AppTypography.bodyXLarge,
                    weight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
                CardBrandMark(
                  brand: BankCard.brandOf(number),
                  size: 52,
                ),
              ],
            ),
            const Spacer(),
            // Scales down instead of wrapping when the digits run wide.
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                BankCard.printed(number),
                style: AppTypography.body(
                  AppTypography.bodyXLarge,
                  weight: FontWeight.w600,
                  color: AppColors.white,
                ).copyWith(letterSpacing: 1.6),
              ),
            ),
            const Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  flex: 3,
                  child: _PreviewLabel(
                    label: 'Card Holder',
                    value: holder.isEmpty ? 'YOUR NAME' : holder.toUpperCase(),
                    hint: dimmed,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: _PreviewLabel(
                    label: 'Expires',
                    value: expiry.isEmpty ? 'MM/YY' : expiry,
                    hint: dimmed,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewLabel extends StatelessWidget {
  const _PreviewLabel({
    required this.label,
    required this.value,
    required this.hint,
  });

  final String label;
  final String value;
  final Color hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTypography.body(AppTypography.bodyXSmall, color: hint),
        ),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.body(
            AppTypography.bodyMedium,
            weight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.obscureText = false,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.error,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final bool obscureText;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.body(
            AppTypography.bodyXLarge,
            weight: FontWeight.w700,
            color: context.inkPrimary,
          ),
        ),
        const SizedBox(height: Insets.gapMd),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          textCapitalization: textCapitalization,
          inputFormatters: inputFormatters,
          style: AppTypography.body(
            AppTypography.bodyLarge,
            weight: FontWeight.w600,
            color: context.inkPrimary,
          ),
          decoration: InputDecoration(hintText: hint, errorText: error),
        ),
      ],
    );
  }
}

/// Re-groups the raw digits into `1234 5678 9012 3456` while typing.
class _GroupOfFour extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final grouped = BankCard.grouped(digits);
    return TextEditingValue(
      text: grouped,
      selection: TextSelection.collapsed(offset: grouped.length),
    );
  }
}

/// Digits in, `MM/YY` out — auto-pads a single leading month digit.
class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 4) digits = digits.substring(0, 4);
    if (digits.length == 1 && int.parse(digits) > 1) digits = '0$digits';
    final month = digits.substring(0, digits.length.clamp(0, 2));
    final rest = digits.length > 2 ? digits.substring(2) : '';
    final text = rest.isEmpty ? month : '$month/$rest';
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

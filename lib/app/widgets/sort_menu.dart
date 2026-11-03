import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';

/// One row of the `7_home songs sort option` menu.
class SortChoice<T> {
  const SortChoice(this.value, this.label);

  final T value;
  final String label;
}

/// Anchored dropdown of radio rows shown under the count/sort bar.
Future<T?> showSortMenu<T>(
  BuildContext context, {
  required List<SortChoice<T>> choices,
  required T selected,
}) {
  final box = context.findRenderObject() as RenderBox?;
  if (box == null) return Future.value();
  final origin = box.localToGlobal(Offset.zero);
  return showMenu<T>(
    context: context,
    color: context.cardBackground,
    elevation: 12,
    constraints: const BoxConstraints.tightFor(width: 196),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(Insets.radiusLg),
    ),
    position: RelativeRect.fromLTRB(
      origin.dx + box.size.width - 196,
      origin.dy + box.size.height + Insets.gapSm,
      origin.dx + box.size.width,
      origin.dy,
    ),
    items: [
      for (var i = 0; i < choices.length; i++) ...[
        if (i > 0) const PopupMenuDivider(height: 1),
        PopupMenuItem<T>(
          value: choices[i].value,
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: Insets.gapLg),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  choices[i].label,
                  style: AppTypography.body(
                    AppTypography.bodyLarge,
                    weight: FontWeight.w600,
                    color: context.inkPrimary,
                  ),
                ),
              ),
              Icon(
                choices[i].value == selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: AppColors.primary,
                size: 22,
              ),
            ],
          ),
        ),
      ],
    ],
  );
}

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';
import 'sheets.dart';

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
  return showMumeSheet<T>(
    context,
    builder: (ctx) => MumeSheet(
      maxHeightFactor: 0.7,
      children: [
        for (var i = 0; i < choices.length; i++) ...[
          if (i > 0) Divider(color: ctx.separatorColor),
          InkWell(
            onTap: () => Navigator.of(ctx).pop(choices[i].value),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: Insets.gapLg),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      choices[i].label,
                      style: AppTypography.body(
                        AppTypography.bodyXLarge,
                        weight: FontWeight.w600,
                        color: ctx.inkPrimary,
                      ),
                    ),
                  ),
                  Icon(
                    choices[i].value == selected
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    ),
  );
}

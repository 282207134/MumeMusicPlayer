import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

/// Surface/ink roles that flip between the Light and Dark boards.
@immutable
class AppInk extends ThemeExtension<AppInk> {
  const AppInk({
    required this.page,
    required this.card,
    required this.tint,
    required this.divider,
    required this.ink,
    required this.inkMuted,
    required this.inkSoft,
    required this.onPrimary,
  });

  final Color page;
  final Color card;
  final Color tint;
  final Color divider;
  final Color ink;
  final Color inkMuted;
  final Color inkSoft;
  final Color onPrimary;

  static const light = AppInk(
    page: AppColors.white,
    card: AppColors.white,
    tint: AppColors.bgOrange,
    divider: AppColors.grey200,
    ink: AppColors.grey900,
    inkMuted: AppColors.grey600,
    inkSoft: AppColors.grey500,
    onPrimary: AppColors.white,
  );

  static const dark = AppInk(
    page: AppColors.dark1,
    card: AppColors.dark2,
    tint: AppColors.dark2,
    divider: AppColors.dark3,
    ink: AppColors.white,
    inkMuted: AppColors.grey400,
    inkSoft: AppColors.grey600,
    onPrimary: AppColors.white,
  );

  @override
  AppInk copyWith({
    Color? page,
    Color? card,
    Color? tint,
    Color? divider,
    Color? ink,
    Color? inkMuted,
    Color? inkSoft,
    Color? onPrimary,
  }) =>
      AppInk(
        page: page ?? this.page,
        card: card ?? this.card,
        tint: tint ?? this.tint,
        divider: divider ?? this.divider,
        ink: ink ?? this.ink,
        inkMuted: inkMuted ?? this.inkMuted,
        inkSoft: inkSoft ?? this.inkSoft,
        onPrimary: onPrimary ?? this.onPrimary,
      );

  @override
  AppInk lerp(ThemeExtension<AppInk>? other, double t) {
    if (other is! AppInk) return this;
    return AppInk(
      page: Color.lerp(page, other.page, t)!,
      card: Color.lerp(card, other.card, t)!,
      tint: Color.lerp(tint, other.tint, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      inkMuted: Color.lerp(inkMuted, other.inkMuted, t)!,
      inkSoft: Color.lerp(inkSoft, other.inkSoft, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
    );
  }
}

extension AppInkContext on BuildContext {
  AppInk get ink => Theme.of(this).extension<AppInk>()!;
  Color get inkPrimary => ink.ink;
  Color get inkMuted => ink.inkMuted;
  Color get inkSoft => ink.inkSoft;
  Color get pageBackground => ink.page;
  Color get cardBackground => ink.card;
  Color get tintBackground => ink.tint;
  Color get separatorColor => ink.divider;
}

abstract final class AppTheme {
  static ThemeData light() => _build(Brightness.light, AppInk.light);

  static ThemeData dark() => _build(Brightness.dark, AppInk.dark);

  static ThemeData _build(Brightness brightness, AppInk ink) {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: ink.page,
      error: AppColors.error,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: AppTypography.fontFamily,
      scaffoldBackgroundColor: ink.page,
      extensions: [ink],
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: ink.ink,
        displayColor: ink.ink,
        fontFamily: AppTypography.fontFamily,
      ),
      iconTheme: IconThemeData(color: ink.ink, size: 24),
      dividerTheme: DividerThemeData(color: ink.divider, thickness: 1, space: 1),
      appBarTheme: AppBarTheme(
        backgroundColor: ink.page,
        foregroundColor: ink.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.heading(AppTypography.h4, color: ink.ink),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: ink.page,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: ink.page,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: ink.ink,
        textColor: ink.ink,
        titleTextStyle: AppTypography.body(
          AppTypography.bodyXLarge,
          weight: FontWeight.w600,
          color: ink.ink,
        ),
        subtitleTextStyle: AppTypography.body(
          AppTypography.bodyMedium,
          color: ink.inkMuted,
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: ink.divider,
        thumbColor: AppColors.primary,
        overlayColor: AppColors.primary.withValues(alpha: 0.15),
        trackHeight: 8,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.primary
              : AppColors.white,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.primary.withValues(alpha: 0.45)
              : ink.divider,
        ),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ink.tint,
        hintStyle: AppTypography.body(AppTypography.bodyLarge, color: ink.inkSoft),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: ink.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: ink.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTypography.body(
            AppTypography.bodyLarge,
            weight: FontWeight.w600,
          ),
        ),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.primary,
        selectionColor: Color(0x40FF8216),
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// Type ramp from `Design System > Typography`. Font family is Urbanist,
/// headings are Bold, body styles ship in all four weights.
abstract final class AppTypography {
  static const fontFamily = 'Urbanist';

  static const h1 = 48.0;
  static const h2 = 40.0;
  static const h3 = 32.0;
  static const h4 = 24.0;
  static const h5 = 20.0;
  static const h6 = 18.0;

  static const bodyXLarge = 18.0;
  static const bodyLarge = 16.0;
  static const bodyMedium = 14.0;
  static const bodySmall = 12.0;
  static const bodyXSmall = 10.0;

  static TextStyle heading(double size, {Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: size,
        height: 1.2,
        fontWeight: FontWeight.w700,
        color: color,
      );

  static TextStyle body(
    double size, {
    FontWeight weight = FontWeight.w400,
    Color? color,
  }) =>
      TextStyle(
        fontFamily: fontFamily,
        fontSize: size,
        height: 1.35,
        fontWeight: weight,
        color: color,
      );
}

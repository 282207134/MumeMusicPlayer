import 'package:flutter/material.dart';

/// Raw palette lifted from the Pixso file's `Design System > Colors` board.
abstract final class AppColors {
  // Main
  static const primary = Color(0xFFFF8216);
  static const secondary = Color(0xFFFFD300);

  // Alert & status
  static const success = Color(0xFF0ABE75);
  static const info = Color(0xFF246BFD);
  static const warning = Color(0xFFFACC15);
  static const error = Color(0xFFF75555);
  static const disabled = Color(0xFFD8D8D8);
  static const disabledButton = Color(0xFFE98025);

  // Greyscale
  static const grey900 = Color(0xFF212121);
  static const grey800 = Color(0xFF424242);
  static const grey700 = Color(0xFF616161);
  static const grey600 = Color(0xFF757575);
  static const grey500 = Color(0xFF9E9E9E);
  static const grey400 = Color(0xFFBDBDBD);
  static const grey300 = Color(0xFFE0E0E0);
  static const grey200 = Color(0xFFEEEEEE);
  static const grey100 = Color(0xFFF5F5F5);
  static const grey50 = Color(0xFFFAFAFA);

  // Dark theme
  static const dark1 = Color(0xFF181A20);
  static const dark2 = Color(0xFF1F222A);
  static const dark3 = Color(0xFF35383F);

  // Background tints
  static const bgOrange = Color(0xFFFFF5ED);
  static const bgYellow = Color(0xFFFFFEE0);
  static const bgGreen = Color(0xFFF5FFF9);
  static const bgPurple = Color(0xFFF7ECFF);
  static const bgBlue = Color(0xFFF6FAFD);
  static const bgPink = Color(0xFFFFF5F5);

  // Full palette used by playlist / category accents
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);
  static const red = Color(0xFFF44336);
  static const pink = Color(0xFFE91E63);
  static const purple = Color(0xFF9C27B0);
  static const deepPurple = Color(0xFF673AB7);
  static const indigo = Color(0xFF3F51B5);
  static const blue = Color(0xFF2196F3);
  static const lightBlue = Color(0xFF03A9F4);
  static const cyan = Color(0xFF00BCD4);
  static const teal = Color(0xFF009688);
  static const green = Color(0xFF4CAF50);
  static const lightGreen = Color(0xFF8BC34A);
  static const lime = Color(0xFFCDDC39);
  static const yellow = Color(0xFFFFEB3B);
  static const amber = Color(0xFFFFC107);
  static const orange = Color(0xFFFF9800);
  static const deepOrange = Color(0xFFFF5722);
  static const brown = Color(0xFF795548);
  static const blueGrey = Color(0xFF607D8B);

  /// The six `Gradients` swatches, expressed as `[topLeft, bottomRight]` stops.
  static const gradientOrange = [Color(0xFFFFB347), Color(0xFFFF7A00)];
  static const gradientYellow = [Color(0xFFFBE97A), Color(0xFFF5B700)];
  static const gradientGreen = [Color(0xFF6BE7A4), Color(0xFF00A868)];
  static const gradientPurple = [Color(0xFFB06BFF), Color(0xFF7A00E0)];
  static const gradientBlue = [Color(0xFF6EC1FF), Color(0xFF1E6FE0)];
  static const gradientRed = [Color(0xFFFF8A8A), Color(0xFFE53935)];
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography scale — Manrope throughout. Numeral-heavy styles (money,
/// counts, quantities) should layer [tabular] on top so digits don't jitter.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle _base({
    required double size,
    required FontWeight weight,
    required Color color,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.manrope(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle display({Color color = AppColors.ink}) =>
      _base(size: 32, weight: FontWeight.w700, color: color, height: 38 / 32);

  static TextStyle h1({Color color = AppColors.ink}) =>
      _base(size: 24, weight: FontWeight.w700, color: color, height: 30 / 24);

  static TextStyle h2({Color color = AppColors.ink}) =>
      _base(size: 20, weight: FontWeight.w600, color: color, height: 26 / 20);

  static TextStyle title({Color color = AppColors.ink}) =>
      _base(size: 17, weight: FontWeight.w600, color: color, height: 22 / 17);

  static TextStyle body({Color color = AppColors.ink}) =>
      _base(size: 15, weight: FontWeight.w400, color: color, height: 22 / 15);

  static TextStyle label({Color color = AppColors.inkMuted}) =>
      _base(size: 13, weight: FontWeight.w500, color: color, height: 18 / 13);

  static TextStyle caption({Color color = AppColors.inkMuted}) => _base(
        size: 11,
        weight: FontWeight.w600,
        color: color,
        height: 14 / 11,
        letterSpacing: 0.6,
      );

  /// Layer onto any style used for money/quantity/count values so digits
  /// occupy fixed-width slots and don't jitter when the value refreshes.
  static TextStyle tabular(TextStyle style) {
    return style.copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }
}

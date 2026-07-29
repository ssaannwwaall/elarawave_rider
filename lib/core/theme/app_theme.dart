import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.snow,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.elaraBlue,
        primary: AppColors.elaraBlue,
        secondary: AppColors.aqua,
        surface: AppColors.snow,
      ),
      textTheme: GoogleFonts.manropeTextTheme(),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.ink,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.elaraBlue,
        selectionColor: AppColors.foam,
        selectionHandleColor: AppColors.aqua,
      ),
      splashFactory: InkRipple.splashFactory,
    );
  }
}

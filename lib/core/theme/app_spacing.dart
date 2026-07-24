/// Spacing scale: 4 / 8 / 12 / 16 / 20 / 24 / 32.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  static const double screenPadding = 16;
  static const double cardPadding = 16;
  static const double cardGap = 12;

  /// Riders tap with thumbs, sometimes wet or gloved. Never go smaller.
  static const double minTapTarget = 48;
}

/// Corner radius scale.
class AppRadius {
  AppRadius._();

  static const double button = 16;
  static const double chip = 14;
  static const double card = 20;
  static const double sheet = 28;
  static const double pill = 999;
}

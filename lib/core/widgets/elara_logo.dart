import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart' show AppTextStyles;
import '../theme/app_colors.dart' show AppColors;

/// The real Elara Wave mark (assets/brand/logo-mark.png, cropped from the
/// client's own logo export — see docs/DESIGN_SYSTEM.md for provenance).
/// The wordmark is set in our own type rather than the logo file's baked-in
/// navy text; it defaults to dark ink so it stays legible on the light,
/// near-white water backgrounds used across the app. Pass [wordmarkColor]
/// to adapt it for any darker surface.
class ElaraLogo extends StatelessWidget {
  final double size;
  final bool showIcon;
  final bool showWordmark;
  final Color wordmarkColor;

  const ElaraLogo({
    super.key,
    this.size = 72,
    this.showIcon = true,
    this.showWordmark = true,
    this.wordmarkColor = AppColors.ink,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showIcon)
          Image.asset(
            'assets/brand/logo-mark.png',
            width: size,
            height: size,
            fit: BoxFit.contain,
          ),
        if (showWordmark) ...[
          const SizedBox(height: 12),
          Text(
            'ELARA WAVE',
            style: AppTextStyles.h2(color: wordmarkColor).copyWith(letterSpacing: 1.4),
          ),
          const SizedBox(height: 2),
          Text(
            'FLOW WITH FRESHNESS',
            style: AppTextStyles.caption(
              color: wordmarkColor == Colors.white
                  ? Colors.white.withValues(alpha: 0.75)
                  : AppColors.inkMuted,
            ),
          ),
        ],
      ],
    );
  }
}

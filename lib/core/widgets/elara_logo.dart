import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart' show AppTextStyles;
import '../theme/app_colors.dart' show AppColors;

/// The real Elara Wave mark (assets/brand/logo-mark.png, cropped from the
/// client's own logo export — see docs/DESIGN_SYSTEM.md for provenance).
/// The wordmark is set in our own type rather than the logo file's baked-in
/// navy text, since that text is illegible on the dark water zones this
/// mark is mostly used against; pass [wordmarkColor] to adapt it per screen.
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
    this.wordmarkColor = Colors.white,
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

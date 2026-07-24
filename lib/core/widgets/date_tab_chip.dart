import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../../presentation/widgets/water/purity_ripple.dart';

class DateTabChip extends StatelessWidget {
  final String topLabel;
  final String bottomLabel;
  final bool selected;
  final VoidCallback onTap;

  const DateTabChip({
    super.key,
    required this.topLabel,
    required this.bottomLabel,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) => PurityRipple.showAt(context, details.globalPosition),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        constraints: const BoxConstraints(minHeight: AppSpacing.minTapTarget),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: selected ? AppColors.elaraBlue : AppColors.mist,
          borderRadius: BorderRadius.circular(AppRadius.chip),
          border: selected ? null : Border.all(color: AppColors.line),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              topLabel,
              style: AppTextStyles.caption(
                color: selected ? Colors.white.withValues(alpha: 0.85) : AppColors.inkMuted,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              bottomLabel,
              style: AppTextStyles.body(color: selected ? Colors.white : AppColors.ink)
                  .copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

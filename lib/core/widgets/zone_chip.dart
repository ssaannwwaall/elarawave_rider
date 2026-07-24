import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class ZoneChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const ZoneChip({super.key, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        constraints: const BoxConstraints(minHeight: 40),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: selected ? AppColors.foam : AppColors.mist,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: selected ? AppColors.elaraBlue : AppColors.line),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.label(color: selected ? AppColors.elaraBlue : AppColors.inkMuted)
                .copyWith(fontWeight: selected ? FontWeight.w700 : FontWeight.w500),
          ),
        ),
      ),
    );
  }
}

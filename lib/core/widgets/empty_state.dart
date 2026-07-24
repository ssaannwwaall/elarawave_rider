import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// A still, softly-lit water surface glyph — calm, not sad. Motion is
/// reserved for loading states; empty states stay static by design.
class EmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Icons.waves_rounded,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.foam,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 38, color: AppColors.elaraBlue),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            title,
            style: AppTextStyles.title().copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Text(
                subtitle!,
                style: AppTextStyles.body(color: AppColors.inkMuted),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: AppSpacing.lg),
            TextButton(
              onPressed: onAction,
              child: Text(
                actionLabel!,
                style: AppTextStyles.label(color: AppColors.elaraBlue).copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

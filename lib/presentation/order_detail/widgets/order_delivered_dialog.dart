import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/primary_button.dart';

/// Celebratory confirmation shown when an order is marked delivered.
/// [onDone] fires when the rider taps "Back to orders".
class OrderDeliveredDialog extends StatelessWidget {
  final String? orderLabel;
  final VoidCallback onDone;

  const OrderDeliveredDialog({super.key, required this.onDone, this.orderLabel});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.snow,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sheet)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.xxl,
          AppSpacing.xl,
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.mineral.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, size: 56, color: AppColors.mineral),
            )
                .animate()
                .scale(
                  begin: const Offset(0.4, 0.4),
                  end: const Offset(1, 1),
                  duration: 420.ms,
                  curve: Curves.easeOutBack,
                )
                .fadeIn(duration: 220.ms),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Order delivered',
              style: AppTextStyles.h1(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              orderLabel != null
                  ? 'Order $orderLabel has been marked as delivered. Nice work!'
                  : 'This order has been marked as delivered. Nice work!',
              style: AppTextStyles.body(color: AppColors.inkMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(label: 'Back to orders', onPressed: onDone),
          ],
        ),
      ),
    );
  }
}

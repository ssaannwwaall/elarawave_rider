import 'package:flutter/material.dart';
import '../constants/order_status.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class StatusBadge extends StatelessWidget {
  /// Machine-readable status key (`order_status`), used to pick a color.
  final String? statusKey;
  /// Human-readable label (`order_status_label`) to display.
  final String? label;

  const StatusBadge({super.key, required this.statusKey, required this.label});

  @override
  Widget build(BuildContext context) {
    final text = label ?? OrderStatus.labelFor(statusKey);
    if (text.trim().isEmpty) return const SizedBox.shrink();

    final color = OrderStatus.colorFor(statusKey);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption(color: color).copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

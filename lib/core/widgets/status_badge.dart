import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Color per machine-readable `order_status` key. Only `ready` is confirmed
/// so far (docs/API.md) — add more keys here as the backend confirms them.
/// Deliberately a map, not a closed enum: an unseen status still renders
/// sensibly via the neutral-grey fallback instead of breaking.
const Map<String, Color> _statusColors = {
  'ready': AppColors.amber,
  // TODO: confirm and add delivered (-> mineral), cancelled (-> coral),
  // pending (-> amber) once the backend documents their exact keys.
};

const Color _fallbackColor = AppColors.inkMuted;

class StatusBadge extends StatelessWidget {
  /// Machine-readable status key (`order_status`), used to pick a color.
  final String? statusKey;
  /// Human-readable label (`order_status_label`) to display.
  final String? label;

  const StatusBadge({super.key, required this.statusKey, required this.label});

  @override
  Widget build(BuildContext context) {
    final text = label ?? statusKey;
    if (text == null || text.trim().isEmpty) return const SizedBox.shrink();

    final color = _statusColors[statusKey?.toLowerCase().trim()] ?? _fallbackColor;

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

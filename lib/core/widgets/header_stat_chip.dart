import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Today's Orders/Sold/Cash, laid out on frosted glass chips directly on
/// the light water header — dark ink text, since the header background is
/// now a bright water blue, not a dark navy. Tabular figures so digits
/// don't jitter when a refresh lands.
class HeaderStatChip extends StatelessWidget {
  final String label;
  final String value;

  const HeaderStatChip({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: AppTextStyles.tabular(
                AppTextStyles.title(color: AppColors.ink).copyWith(fontWeight: FontWeight.w700),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              label.toUpperCase(),
              style: AppTextStyles.caption(color: AppColors.ink.withValues(alpha: 0.65)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class HeaderStatsRow extends StatelessWidget {
  final int count;
  final num sold;
  final num cash;

  const HeaderStatsRow({super.key, required this.count, required this.sold, required this.cash});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        HeaderStatChip(label: 'Orders', value: '$count'),
        const SizedBox(width: AppSpacing.sm),
        HeaderStatChip(label: 'Sold', value: 'PKR $sold'),
        const SizedBox(width: AppSpacing.sm),
        HeaderStatChip(label: 'Cash', value: 'PKR $cash'),
      ],
    );
  }
}

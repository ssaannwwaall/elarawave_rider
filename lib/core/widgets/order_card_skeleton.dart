import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Shimmer skeleton shown while the to-do list is loading — three of these
/// stacked, never a bare spinner over the order list area.
class OrderCardSkeleton extends StatelessWidget {
  const OrderCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.line,
      highlightColor: AppColors.mist,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.snow,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _bar(width: 70, height: 16),
                const Spacer(),
                _bar(width: 56, height: 20, radius: AppRadius.pill),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                _circle(36),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _bar(width: 120, height: 14),
                      const SizedBox(height: 6),
                      _bar(width: 80, height: 12),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _bar(width: double.infinity, height: 36),
            const SizedBox(height: AppSpacing.md),
            _bar(width: 100, height: 18),
          ],
        ),
      ),
    );
  }

  Widget _bar({required double width, required double height, double radius = 8}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(radius)),
    );
  }

  Widget _circle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
    );
  }
}

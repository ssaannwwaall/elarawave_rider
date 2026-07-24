import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/header_stat_chip.dart';
import '../../widgets/water/liquid_caustics_background.dart';
import '../home_controller.dart';
import 'logout_sheet.dart';

class WaterHeader extends StatelessWidget {
  final HomeController controller;
  final int orderCount;
  final num sold;
  final num cash;

  const WaterHeader({
    super.key,
    required this.controller,
    required this.orderCount,
    required this.sold,
    required this.cash,
  });

  String get _initials {
    final parts = controller.rider.name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    final first = parts.first[0];
    final second = parts.length > 1 && parts[1].isNotEmpty ? parts[1][0] : '';
    return (first + second).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return LiquidCausticsBackground(
      colorDeep: AppColors.waterDeep,
      colorLight: AppColors.waterLight,
      intensity: 0.85,
      // This is the *only* non-positioned child inside LiquidCausticsBackground's
      // own Stack, so it's what determines the header's height — see that
      // widget's build() comment (the header sits in a Sliver with no
      // bounded height to expand into).
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPadding,
            AppSpacing.md,
            AppSpacing.screenPadding,
            AppSpacing.lg,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white.withValues(alpha: 0.6),
                    child: Text(
                      _initials,
                      style: AppTextStyles.body(color: AppColors.ink).copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.greeting,
                          style: AppTextStyles.caption(color: AppColors.ink.withValues(alpha: 0.7)),
                        ),
                        Text(
                          controller.rider.name,
                          style: AppTextStyles.h2(color: AppColors.ink),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Non-functional placeholder — no notifications API documented yet.
                  IconButton(
                    onPressed: null,
                    icon: Icon(Icons.notifications_none_rounded, color: AppColors.ink.withValues(alpha: 0.75)),
                  ),
                  IconButton(
                    tooltip: 'Sign out',
                    onPressed: () => showLogoutSheet(context, onConfirm: controller.logout),
                    icon: Icon(Icons.power_settings_new_rounded, color: AppColors.ink.withValues(alpha: 0.75)),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              HeaderStatsRow(count: orderCount, sold: sold, cash: cash),
            ],
          ),
        ),
      ),
    );
  }
}

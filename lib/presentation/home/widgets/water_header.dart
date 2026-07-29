import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/header_stat_chip.dart';
import '../../widgets/water/liquid_caustics_background.dart';
import '../home_controller.dart';
import 'logout_sheet.dart';

/// Instagram-profile-style collapsing header. Pinned to the top: as the list
/// scrolls down it squeezes to a compact bar (just avatar + name + actions,
/// stats fade/collapse away); scrolling back up expands it to full size.
///
/// Driven by [SliverPersistentHeader]'s shrinkOffset — no scroll listeners,
/// so it stays perfectly in sync with the scroll position both ways.
class HomeHeaderDelegate extends SliverPersistentHeaderDelegate {
  final HomeController controller;
  final double topInset;

  HomeHeaderDelegate({required this.controller, required this.topInset});

  // Content heights (below the status-bar inset). Kept comfortably above the
  // real content so the header never overflows as it interpolates.
  static const double _expandedContent = 160;
  static const double _collapsedContent = 68;

  @override
  double get maxExtent => topInset + _expandedContent;

  @override
  double get minExtent => topInset + _collapsedContent;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    // 0.0 fully expanded -> 1.0 fully collapsed.
    final t = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);

    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(
            child: LiquidCausticsBackground(
              colorDeep: AppColors.heroDeep,
              colorLight: AppColors.heroLight,
              intensity: 0.7,
            ),
          ),
          // Positioned (not a full-height Padding) so the content sizes to
          // itself and is simply clipped by the ClipRect as the header
          // squeezes — no height constraint means no overflow errors, ever.
          Positioned(
            top: topInset,
            left: AppSpacing.screenPadding,
            right: AppSpacing.screenPadding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: AppSpacing.md),
                _TopRow(controller: controller),
                // Stats block: collapses its height (heightFactor) and fades
                // out as the header squeezes, then reappears on scroll-up.
                Align(
                  alignment: Alignment.topCenter,
                  heightFactor: 1 - t,
                  child: Opacity(
                    opacity: 1 - t,
                    child: Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.lg),
                      child: Obx(() {
                        final s = controller.todaySummary.value;
                        return HeaderStatsRow(count: s.count, sold: s.sold, cash: s.cash);
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant HomeHeaderDelegate oldDelegate) =>
      oldDelegate.topInset != topInset || oldDelegate.controller != controller;
}

/// Avatar + greeting/name + action icons. Always visible; this is the row the
/// header collapses down to.
class _TopRow extends StatelessWidget {
  final HomeController controller;

  const _TopRow({required this.controller});

  String get _initials {
    final parts = controller.rider.name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    final first = parts.first[0];
    final second = parts.length > 1 && parts[1].isNotEmpty ? parts[1][0] : '';
    return (first + second).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Get.toNamed(AppRoutes.profile),
          child: Builder(
            builder: (_) {
              final rider = controller.rider;
              return CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white.withValues(alpha: 0.6),
                backgroundImage: rider.hasPhoto ? NetworkImage(rider.photoUrl) : null,
                child: rider.hasPhoto
                    ? null
                    : Text(
                        _initials,
                        style: AppTextStyles.body(color: AppColors.ink)
                            .copyWith(fontWeight: FontWeight.w700),
                      ),
              );
            },
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                controller.greeting,
                style: AppTextStyles.caption(color: AppColors.ink.withValues(alpha: 0.7)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
        IconButton(
          tooltip: 'Customers',
          onPressed: () => Get.toNamed(AppRoutes.customers),
          icon: Icon(Icons.people_alt_outlined, color: AppColors.ink.withValues(alpha: 0.75)),
        ),
        IconButton(
          tooltip: 'Sign out',
          onPressed: () => showLogoutSheet(context, onConfirm: controller.logout),
          icon: Icon(Icons.power_settings_new_rounded, color: AppColors.ink.withValues(alpha: 0.75)),
        ),
      ],
    );
  }
}

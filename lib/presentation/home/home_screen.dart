import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/order_card_skeleton.dart';
import 'home_controller.dart';
import 'widgets/date_tabs_row.dart';
import 'widgets/order_list_item.dart';
import 'widgets/water_header.dart';
import 'widgets/water_pull_to_refresh.dart';
import 'widgets/zone_filter_row.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: AppColors.snow,
      body: WaterPullToRefresh(
        onRefresh: controller.refreshData,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: HomeHeaderDelegate(
                controller: controller,
                topInset: MediaQuery.paddingOf(context).top,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
            SliverToBoxAdapter(
              child: Obx(
                () => DateTabsRow(
                  dates: controller.dates,
                  selectedIndex: controller.selectedDateIndex.value,
                  onSelected: controller.selectDate,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
            SliverToBoxAdapter(
              child: Obx(
                () => ZoneFilterRow(
                  zones: controller.zones.toList(),
                  selectedZoneId: controller.selectedZoneId.value,
                  onSelected: controller.selectZone,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding,
                  AppSpacing.lg,
                  AppSpacing.screenPadding,
                  0,
                ),
                child: _SearchField(controller: controller),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding,
                  AppSpacing.xl,
                  AppSpacing.screenPadding,
                  AppSpacing.sm,
                ),
                child: Text('Deliveries', style: AppTextStyles.h2()),
              ),
            ),
            Obx(() => _buildContentSliver(context, controller)),
          ],
        ),
      ),
    );
  }

  Widget _buildContentSliver(BuildContext context, HomeController controller) {
    if (controller.isLoadingToDo.value) {
      return SliverPadding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          0,
          AppSpacing.screenPadding,
          AppSpacing.xxxl,
        ),
        sliver: SliverList.separated(
          itemCount: 3,
          separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.cardGap),
          itemBuilder: (context, index) => const OrderCardSkeleton(),
        ),
      );
    }

    if (controller.scheduleNotPublished.value) {
      return SliverToBoxAdapter(
        child: EmptyState(
          icon: Icons.event_available_outlined,
          title: 'Schedule not published yet',
          subtitle: "This day's route hasn't been published. Check back closer to the date.",
        ),
      );
    }

    if (controller.errorMessage.value != null) {
      return SliverToBoxAdapter(
        child: EmptyState(
          icon: Icons.wifi_off_rounded,
          title: 'Could not load deliveries',
          subtitle: controller.errorMessage.value,
          actionLabel: 'Retry',
          onAction: controller.refreshData,
        ),
      );
    }

    final orders = controller.toDoList.value?.orders ?? [];
    if (orders.isEmpty) {
      return SliverToBoxAdapter(
        child: EmptyState(
          title: 'No deliveries scheduled for today',
          subtitle: 'Pull down to refresh once new orders come in.',
          actionLabel: 'Refresh',
          onAction: controller.refreshData,
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        0,
        AppSpacing.screenPadding,
        AppSpacing.xxxl,
      ),
      sliver: SliverList.separated(
        itemCount: orders.length,
        separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.cardGap),
        itemBuilder: (context, index) => OrderListItem(order: orders[index], index: index),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final HomeController controller;

  const _SearchField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.snow,
        borderRadius: BorderRadius.circular(AppRadius.button),
        border: Border.all(color: AppColors.line),
      ),
      child: TextField(
        onChanged: controller.onSearchChanged,
        style: AppTextStyles.body(),
        decoration: InputDecoration(
          hintText: 'Search orders...',
          hintStyle: AppTextStyles.body(color: AppColors.inkFaint),
          prefixIcon: const Icon(Icons.search, color: AppColors.inkFaint),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}

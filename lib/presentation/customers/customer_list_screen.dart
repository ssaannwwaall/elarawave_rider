import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/order_card_skeleton.dart';
import '../../core/widgets/zone_chip.dart';
import 'customer_list_controller.dart';
import 'widgets/customer_list_item.dart';

class CustomerListScreen extends GetView<CustomerListController> {
  const CustomerListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.snow,
      appBar: AppBar(
        backgroundColor: AppColors.snow,
        elevation: 0,
        title: Text('Customers', style: AppTextStyles.h2()),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.openCreate,
        backgroundColor: AppColors.elaraBlue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: Text(
          'Add customer',
          style: AppTextStyles.label(color: Colors.white).copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              AppSpacing.md,
              AppSpacing.screenPadding,
              0,
            ),
            child: _SearchField(controller: controller),
          ),
          _ZoneFilter(controller: controller),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.elaraBlue,
              onRefresh: controller.refreshCustomers,
              child: Obx(() => _buildBody(context)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (controller.isLoading.value) {
      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          AppSpacing.lg,
          AppSpacing.screenPadding,
          AppSpacing.xxxl,
        ),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.cardGap),
        itemBuilder: (_, __) => const OrderCardSkeleton(),
      );
    }

    if (controller.errorMessage.value != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          EmptyState(
            icon: Icons.wifi_off_rounded,
            title: 'Could not load customers',
            subtitle: controller.errorMessage.value,
            actionLabel: 'Retry',
            onAction: controller.refreshCustomers,
          ),
        ],
      );
    }

    final customers = controller.customers;
    if (customers.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          EmptyState(
            icon: Icons.people_alt_outlined,
            title: 'No customers yet',
            subtitle: controller.query.value.isNotEmpty
                ? 'No customers match your search.'
                : 'Add your first customer with the button below.',
            actionLabel: 'Add customer',
            onAction: controller.openCreate,
          ),
        ],
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
          controller.loadMore();
        }
        return false;
      },
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          AppSpacing.lg,
          AppSpacing.screenPadding,
          AppSpacing.xxxl + 64, // room for the FAB
        ),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: customers.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.cardGap),
        itemBuilder: (context, index) {
          if (index == customers.length) {
            return Obx(
              () => controller.isLoadingMore.value
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                      child: Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.elaraBlue),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            );
          }
          return CustomerListItem(customer: customers[index], index: index);
        },
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final CustomerListController controller;

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
          hintText: 'Search name, code, phone, address...',
          hintStyle: AppTextStyles.body(color: AppColors.inkFaint),
          prefixIcon: const Icon(Icons.search, color: AppColors.inkFaint),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}

class _ZoneFilter extends StatelessWidget {
  final CustomerListController controller;

  const _ZoneFilter({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final zones = controller.zones;
      if (zones.isEmpty) return const SizedBox(height: AppSpacing.md);
      final selected = controller.selectedZoneId.value;
      return SizedBox(
      height: 40 + AppSpacing.md * 2,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          AppSpacing.md,
          AppSpacing.screenPadding,
          AppSpacing.md,
        ),
        children: [
          ZoneChip(
            label: 'All zones',
            selected: selected == null,
            onTap: () => controller.selectZone(null),
          ),
          const SizedBox(width: AppSpacing.sm),
          for (final zone in zones) ...[
            ZoneChip(
              label: zone.name,
              selected: selected == zone.id,
              onTap: () => controller.selectZone(zone.id),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
        ],
      ),
    );
    });
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/order_card_skeleton.dart';
import '../../core/widgets/zone_chip.dart';
import '../../domain/entities/item.dart';
import 'item_picker_controller.dart';

final _moneyFormat = NumberFormat('#,##0.##');

/// Full-screen product picker. Tapping a product returns it to the order
/// screen via `Get.back(result: item)`.
class ItemPickerScreen extends GetView<ItemPickerController> {
  const ItemPickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.snow,
      appBar: AppBar(
        backgroundColor: AppColors.snow,
        elevation: 0,
        title: Text('Add product', style: AppTextStyles.h2()),
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
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.snow,
                borderRadius: BorderRadius.circular(AppRadius.button),
                border: Border.all(color: AppColors.line),
              ),
              child: TextField(
                onChanged: controller.onSearchChanged,
                style: AppTextStyles.body(),
                decoration: InputDecoration(
                  hintText: 'Search name or barcode...',
                  hintStyle: AppTextStyles.body(color: AppColors.inkFaint),
                  prefixIcon: const Icon(Icons.search, color: AppColors.inkFaint),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 40 + AppSpacing.md * 2,
            child: Obx(
              () => ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding,
                  AppSpacing.md,
                  AppSpacing.screenPadding,
                  AppSpacing.md,
                ),
                children: [
                  ZoneChip(
                    label: 'All',
                    selected: controller.itemType.value == null,
                    onTap: () => controller.selectType(null),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  ZoneChip(
                    label: 'Finished goods',
                    selected: controller.itemType.value == 'finished_good',
                    onTap: () => controller.selectType('finished_good'),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  ZoneChip(
                    label: 'Trade items',
                    selected: controller.itemType.value == 'trade_item',
                    onTap: () => controller.selectType('trade_item'),
                  ),
                ],
              ),
            ),
          ),
          Expanded(child: Obx(() => _buildBody())),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (controller.isLoading.value) {
      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          AppSpacing.lg,
          AppSpacing.screenPadding,
          AppSpacing.xxxl,
        ),
        itemCount: 5,
        separatorBuilder: (_, i) => const SizedBox(height: AppSpacing.cardGap),
        itemBuilder: (_, i) => const OrderCardSkeleton(),
      );
    }

    if (controller.errorMessage.value != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          EmptyState(
            icon: Icons.wifi_off_rounded,
            title: 'Could not load products',
            subtitle: controller.errorMessage.value,
            actionLabel: 'Retry',
            onAction: controller.load,
          ),
        ],
      );
    }

    final items = controller.items;
    if (items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          EmptyState(
            icon: Icons.inventory_2_outlined,
            title: 'No products found',
            subtitle: 'Try a different search or filter.',
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
          AppSpacing.xxxl,
        ),
        itemCount: items.length + 1,
        separatorBuilder: (_, i) => const SizedBox(height: AppSpacing.cardGap),
        itemBuilder: (context, index) {
          if (index == items.length) {
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
          return _ItemTile(item: items[index]);
        },
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  final Item item;

  const _ItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => Get.back<Item>(result: item),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.foam,
              borderRadius: BorderRadius.circular(AppRadius.chip),
            ),
            child: const Icon(Icons.water_drop_outlined, color: AppColors.elaraBlue),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.itemName,
                  style: AppTextStyles.title().copyWith(fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    item.itemTypeLabel,
                    if (item.barcodeNo.trim().isNotEmpty) item.barcodeNo.trim(),
                    'Stock ${_moneyFormat.format(item.openingStockQty)}',
                  ].where((e) => e.isNotEmpty).join(' · '),
                  style: AppTextStyles.label(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'PKR ${_moneyFormat.format(item.salePrice)}',
                style: AppTextStyles.tabular(
                  AppTextStyles.title().copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              if (item.isRefill)
                Text('Refill', style: AppTextStyles.caption(color: AppColors.aqua)),
            ],
          ),
        ],
      ),
    );
  }
}

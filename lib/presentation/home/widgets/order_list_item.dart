import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../domain/entities/todo_order.dart';

final _moneyFormat = NumberFormat('#,##0');

/// Order card for the Home to-do list, per docs/DESIGN_SYSTEM.md's card
/// mock. Parses against the confirmed `orders[]` schema (docs/API.md) but
/// stays null-safe since only one sample record has been seen and several
/// of its fields (address, geo, phone) are effectively empty placeholders.
class OrderListItem extends StatelessWidget {
  final ToDoOrder order;
  /// Position in the list — drives a capped entrance stagger (first ~8
  /// items only; later items just appear, no one waits in a queue).
  final int index;

  const OrderListItem({super.key, required this.order, this.index = 0});

  String get _orderLabel {
    if (order.orderNo != null) return '#${order.orderNo}';
    if (order.orderId != null) return '#${order.orderId}';
    return 'Order';
  }

  String get _itemsSummary {
    if (order.items.isEmpty) return 'No items listed';
    final first = order.items.first;
    final quantity = first.quantity;
    final name = first.itemName ?? 'Item';
    final label = quantity != null ? '${_formatQuantity(quantity)} × $name' : name;
    if (order.items.length == 1) return label;
    return '$label +${order.items.length - 1} more';
  }

  String _formatQuantity(num quantity) {
    return quantity == quantity.roundToDouble()
        ? quantity.toInt().toString()
        : quantity.toString();
  }

  Future<void> _callCustomer() async {
    final phone = order.customer?.phone;
    if (phone == null) return;
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final customer = order.customer;
    final hasValidPhone = customer?.hasValidPhone ?? false;
    final hasLocation = customer?.hasLocation ?? false;
    final hasBalance = (customer?.balance ?? 0) > 0;

    Widget card = AppCard(
      onTap: order.orderId != null
          ? () => Get.toNamed(AppRoutes.orderDetailPath(order.orderId!), arguments: order)
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: order no · status · time
          Row(
            children: [
              Text(
                _orderLabel,
                style: AppTextStyles.title().copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: AppSpacing.sm),
              StatusBadge(statusKey: order.orderStatus, label: order.orderStatusLabel),
              const Spacer(),
              if (order.orderDatetime != null)
                Text(
                  DateFormat('h:mm a').format(order.orderDatetime!),
                  style: AppTextStyles.tabular(AppTextStyles.label()),
                ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Divider(height: 1, color: AppColors.line),
          ),
          // Customer row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 6),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(color: AppColors.mineral, shape: BoxShape.circle),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer?.name ?? 'Customer',
                      style: AppTextStyles.title().copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (order.zone?.name != null || customer?.partyCode != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        [
                          if (order.zone?.name != null) order.zone!.name,
                          if (customer?.partyCode != null) customer!.partyCode,
                        ].join(' · '),
                        style: AppTextStyles.label(),
                      ),
                    ],
                  ],
                ),
              ),
              _IconAction(
                icon: Icons.call_outlined,
                enabled: hasValidPhone,
                tooltip: hasValidPhone ? 'Call customer' : 'No phone number available',
                onPressed: hasValidPhone ? _callCustomer : null,
              ),
              const SizedBox(width: AppSpacing.sm),
              _IconAction(
                icon: Icons.navigation_outlined,
                enabled: hasLocation,
                tooltip: hasLocation ? 'Navigate' : 'Location unavailable',
                onPressed: hasLocation ? () => Get.snackbar('Navigate', 'Coming soon.') : null,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              const Icon(Icons.inventory_2_outlined, size: 16, color: AppColors.inkMuted),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  _itemsSummary,
                  style: AppTextStyles.body(color: AppColors.inkMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.end,
            runSpacing: AppSpacing.sm,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'PKR ${_moneyFormat.format(order.amount)}',
                    style: AppTextStyles.tabular(
                      AppTextStyles.title().copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  if (!order.isFullyReceived)
                    Text(
                      order.received > 0
                          ? 'PKR ${_moneyFormat.format(order.received)} received'
                          : 'Not yet collected',
                      style: AppTextStyles.tabular(AppTextStyles.caption(color: AppColors.amber)),
                    ),
                ],
              ),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  if (customer?.empty != null)
                    _MetaChip(
                      label: 'Empties due ${customer!.empty}',
                      background: AppColors.foam,
                      color: AppColors.elaraBlue,
                    ),
                  if (hasBalance)
                    _MetaChip(
                      label: 'Balance PKR ${_moneyFormat.format(customer!.balance)}',
                      background: AppColors.coral.withValues(alpha: 0.12),
                      color: AppColors.coral,
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    if (index < 8) {
      card = card
          .animate()
          .fadeIn(duration: 320.ms, delay: (index * 40).ms)
          .slideY(begin: 0.08, end: 0, duration: 320.ms, delay: (index * 40).ms, curve: Curves.easeOutCubic);
    }
    return card;
  }
}

class _MetaChip extends StatelessWidget {
  final String label;
  final Color background;
  final Color color;

  const _MetaChip({required this.label, required this.background, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(AppRadius.pill)),
      child: Text(
        label,
        style: AppTextStyles.tabular(AppTextStyles.caption(color: color)).copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final String tooltip;
  final VoidCallback? onPressed;

  const _IconAction({
    required this.icon,
    required this.enabled,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: enabled ? AppColors.foam : AppColors.mist,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: AppSpacing.minTapTarget,
            height: AppSpacing.minTapTarget,
            child: Icon(
              icon,
              size: 18,
              color: enabled ? AppColors.elaraBlue : AppColors.inkFaint,
            ),
          ),
        ),
      ),
    );
  }
}

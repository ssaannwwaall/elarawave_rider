import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/constants/order_status.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/status_badge.dart';
import '../../domain/entities/todo_order.dart';
import 'order_detail_controller.dart';

final _moneyFormat = NumberFormat('#,##0.##');
final _dateTimeFormat = DateFormat('EEE, d MMM yyyy · h:mm a');
final _dateFormat = DateFormat('EEE, d MMM yyyy');

class OrderDetailScreen extends GetView<OrderDetailController> {
  const OrderDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final order = controller.order;
    final title = order?.orderNo != null
        ? '#${order!.orderNo}'
        : (order?.orderId != null ? '#${order!.orderId}' : 'Order');

    return Scaffold(
      backgroundColor: AppColors.snow,
      appBar: AppBar(
        backgroundColor: AppColors.snow,
        elevation: 0,
        title: Text('Order $title', style: AppTextStyles.h2()),
      ),
      body: order == null
          ? const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
              child: EmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'Order unavailable',
                subtitle: 'This order could not be opened. Go back and try again.',
              ),
            )
          : _OrderBody(order: order),
      bottomNavigationBar: order == null ? null : _StatusBar(order: order),
    );
  }
}

class _StatusBar extends StatelessWidget {
  final ToDoOrder order;
  const _StatusBar({required this.order});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OrderDetailController>();
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.sm,
        AppSpacing.screenPadding,
        AppSpacing.md,
      ),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.line)),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: AppSpacing.md),
          child: Obx(
            () => PrimaryButton(
              label: 'Change status · ${controller.statusLabel.value ?? 'Set status'}',
              isLoading: controller.isUpdating.value,
              onPressed: controller.isUpdating.value
                  ? null
                  : () => _showStatusSheet(context, controller),
            ),
          ),
        ),
      ),
    );
  }

  void _showStatusSheet(BuildContext context, OrderDetailController controller) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.snow,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding,
              vertical: AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Update status', style: AppTextStyles.h2()),
                const SizedBox(height: AppSpacing.md),
                ...OrderStatus.all.map((status) {
                  return Obx(() {
                    final selected = controller.statusKey.value == status.value;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        selected ? Icons.radio_button_checked : Icons.radio_button_off,
                        color: selected ? status.color : AppColors.inkFaint,
                      ),
                      title: Text(status.label, style: AppTextStyles.body()),
                      trailing: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(color: status.color, shape: BoxShape.circle),
                      ),
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        controller.changeStatus(status);
                      },
                    );
                  });
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OrderBody extends StatelessWidget {
  final ToDoOrder order;
  const _OrderBody({required this.order});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OrderDetailController>();
    final customer = order.customer;
    final zone = order.zone;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.lg,
        AppSpacing.screenPadding,
        AppSpacing.xxxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Progress
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Progress', style: AppTextStyles.label()),
                const SizedBox(height: AppSpacing.lg),
                Obx(() => _OrderProgress(statusKey: controller.statusKey.value)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.cardGap),

          // Order summary
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      order.orderNo != null ? '#${order.orderNo}' : 'Order',
                      style: AppTextStyles.title().copyWith(fontWeight: FontWeight.w700),
                    ),
                    const Spacer(),
                    Obx(
                      () => StatusBadge(
                        statusKey: controller.statusKey.value,
                        label: controller.statusLabel.value,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
               // _InfoRow(label: 'Order ID', value: order.orderId?.toString()),
                //_InfoRow(label: 'Serial', value: order.sr?.toString()),
                //_InfoRow(label: 'Type', value: _prettyType(order.orderType)),
                _InfoRow(
                  label: 'Placed',
                  value: order.orderDatetime != null
                      ? _dateTimeFormat.format(order.orderDatetime!)
                      : null,
                ),
                _InfoRow(
                  label: 'Delivery due',
                  value: order.deliveryDueDate != null
                      ? _dateFormat.format(order.deliveryDueDate!)
                      : 'Not set',
                ),
                if (order.notes != null) _InfoRow(label: 'Notes', value: order.notes),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.cardGap),

          // Customer
          if (customer != null) ...[
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Customer', style: AppTextStyles.label()),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    customer.name ?? 'Customer',
                    style: AppTextStyles.title().copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  //_InfoRow(label: 'Party code', value: customer.partyCode),
                  //_InfoRow(label: 'Type', value: customer.typeLabel),
                  _InfoRow(label: 'Phone', value: customer.hasValidPhone ? customer.phone : null),
                  _InfoRow(label: 'Address', value: customer.hasAddress ? customer.address : null),
                  _InfoRow(
                    label: 'Location',
                    value: customer.hasLocation
                        ? '${customer.latitude}, ${customer.longitude}'
                        : null,
                  ),
                  _InfoRow(label: 'Last order', value: customer.lastDays != null ? '${customer.lastDays} days ago' : null),
                  _InfoRow(label: 'Empties due', value: customer.empty?.toString()),
                  _InfoRow(
                    label: 'Balance',
                    value: (customer.balance ?? 0) != 0
                        ? 'PKR ${_moneyFormat.format(customer.balance)}'
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.cardGap),
          ],

          // Zone
          if (zone != null) ...[
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Zone', style: AppTextStyles.label()),
                  const SizedBox(height: AppSpacing.sm),
                  _InfoRow(label: 'Name', value: zone.name),
                 // _InfoRow(label: 'Zone ID', value: zone.id.toString()),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.cardGap),
          ],

          // Items
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Items', style: AppTextStyles.label()),
                const SizedBox(height: AppSpacing.sm),
                if (order.items.isEmpty)
                  Text('No items listed', style: AppTextStyles.body(color: AppColors.inkMuted))
                else
                  ...order.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.itemName ?? 'Item',
                                  style: AppTextStyles.body().copyWith(fontWeight: FontWeight.w600),
                                ),
                              ),
                              Text(
                                'PKR ${_moneyFormat.format(item.lineAmount ?? 0)}',
                                style: AppTextStyles.tabular(
                                  AppTextStyles.body().copyWith(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            [
                              if (item.quantity != null) 'Qty ${item.quantity}',
                              if (item.unitPrice != null) '@ ${_moneyFormat.format(item.unitPrice)}',
                              if (item.emptyReceived != null) 'Empty ${item.emptyReceived}',
                            ].join('  ·  '),
                            style: AppTextStyles.caption(),
                          ),
                        ],
                      ),
                    ),
                  ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Divider(height: 1, color: AppColors.line),
                ),
                _AmountRow(label: 'Total', value: order.amount, bold: true),
                const SizedBox(height: AppSpacing.xs),
                _AmountRow(label: 'Received', value: order.received),
                if (!order.isFullyReceived) ...[
                  const SizedBox(height: AppSpacing.xs),
                  _AmountRow(label: 'Outstanding', value: order.outstanding, color: AppColors.amber),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Horizontal stepper showing where the order sits in the forward fulfilment
/// flow (pending → … → delivered). If the order has been returned, the flow
/// is shown muted with a "Returned" banner instead, since return_order is a
/// branch off the happy path rather than a step along it.
class _OrderProgress extends StatelessWidget {
  final String? statusKey;
  const _OrderProgress({required this.statusKey});

  @override
  Widget build(BuildContext context) {
    final current = OrderStatus.fromValue(statusKey);
    final isReturned = current == OrderStatus.returnOrder;
    final currentIndex = current?.flowIndex ?? -1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isReturned)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: AppSpacing.lg),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: OrderStatus.returnOrder.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.chip),
            ),
            child: Row(
              children: [
                Icon(Icons.assignment_return_outlined,
                    size: 18, color: OrderStatus.returnOrder.color),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'This order was returned',
                  style: AppTextStyles.caption(color: OrderStatus.returnOrder.color)
                      .copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < OrderStatus.flow.length; i++)
              Expanded(
                child: _StepSegment(
                  status: OrderStatus.flow[i],
                  index: i,
                  isFirst: i == 0,
                  // Completed (green) = strictly before the current step.
                  // Current (blue) = exactly the current step.
                  // Remaining (grey) = after. When returned, nothing is
                  // completed and there is no current step.
                  isCompleted: !isReturned && currentIndex >= 0 && i < currentIndex,
                  isCurrent: !isReturned && i == currentIndex,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _StepSegment extends StatelessWidget {
  final OrderStatus status;
  final int index;
  final bool isFirst;
  final bool isCompleted;
  final bool isCurrent;

  const _StepSegment({
    required this.status,
    required this.index,
    required this.isFirst,
    required this.isCompleted,
    required this.isCurrent,
  });

  // Green = completed, Blue = current, Grey = remaining.
  static const Color _green = AppColors.mineral;
  static const Color _blue = AppColors.elaraBlue;
  static const Color _grey = AppColors.line;

  @override
  Widget build(BuildContext context) {
    final dotColor = isCompleted
        ? _green
        : isCurrent
            ? _blue
            : _grey;
    // The connector line entering a step is green once we've moved past the
    // previous step (i.e. this step is completed or is the current one).
    final incomingColor = (isCompleted || isCurrent) ? _green : _grey;
    final labelColor = isCompleted
        ? _green
        : isCurrent
            ? _blue
            : AppColors.inkFaint;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: isFirst
                  ? const SizedBox.shrink()
                  : Container(height: 3, color: incomingColor),
            ),
            _Dot(
              color: dotColor,
              filled: isCompleted || isCurrent,
              isCurrent: isCurrent,
              child: isCompleted
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : Text(
                      '${index + 1}',
                      style: AppTextStyles.caption(
                        color: isCurrent ? Colors.white : AppColors.inkFaint,
                      ).copyWith(fontWeight: FontWeight.w700),
                    ),
            ),
            const Expanded(child: SizedBox.shrink()),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          status.label,
          textAlign: TextAlign.center,
          maxLines: 2,
          style: AppTextStyles.caption(color: labelColor)
              .copyWith(fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500),
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  final bool filled;
  final bool isCurrent;
  final Widget child;

  const _Dot({
    required this.color,
    required this.filled,
    required this.isCurrent,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: filled ? color : AppColors.snow,
        shape: BoxShape.circle,
        border: Border.all(color: filled ? color : AppColors.line, width: 2),
        boxShadow: isCurrent
            ? [BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 6, spreadRadius: 1)]
            : null,
      ),
      child: child,
    );
  }
}

/// Label/value row that hides itself when the value is null/empty.
class _InfoRow extends StatelessWidget {
  final String label;
  final String? value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    if (value == null || value!.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: AppTextStyles.label()),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(value!, style: AppTextStyles.body()),
          ),
        ],
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  final String label;
  final num value;
  final bool bold;
  final Color? color;
  const _AmountRow({required this.label, required this.value, this.bold = false, this.color});

  @override
  Widget build(BuildContext context) {
    final labelStyle = bold
        ? AppTextStyles.title().copyWith(fontWeight: FontWeight.w600)
        : AppTextStyles.body(color: color ?? AppColors.inkMuted);
    final valueStyle = AppTextStyles.tabular(
      bold
          ? AppTextStyles.title().copyWith(fontWeight: FontWeight.w700)
          : AppTextStyles.body(color: color ?? AppColors.ink),
    );
    return Row(
      children: [
        Text(label, style: color != null ? labelStyle.copyWith(color: color) : labelStyle),
        const Spacer(),
        Text('PKR ${_moneyFormat.format(value)}', style: valueStyle),
      ],
    );
  }
}

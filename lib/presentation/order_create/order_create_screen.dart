import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/constants/order_status.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import 'order_create_controller.dart';

final _moneyFormat = NumberFormat('#,##0.##');

class OrderCreateScreen extends GetView<OrderCreateController> {
  const OrderCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.snow,
      appBar: AppBar(
        backgroundColor: AppColors.snow,
        elevation: 0,
        title: Text('New order', style: AppTextStyles.h2()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          AppSpacing.lg,
          AppSpacing.screenPadding,
          AppSpacing.xxxl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _CustomerCard(controller: controller),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Text('Items', style: AppTextStyles.h2()),
                const Spacer(),
                TextButton.icon(
                  onPressed: controller.addItem,
                  icon: const Icon(Icons.add, size: 20, color: AppColors.elaraBlue),
                  label: Text(
                    'Add product',
                    style: AppTextStyles.label(color: AppColors.elaraBlue)
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Obx(() {
              if (controller.lines.isEmpty) {
                return _EmptyCart(onAdd: controller.addItem);
              }
              return Column(
                children: [
                  for (final line in controller.lines)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.cardGap),
                      child: _LineTile(
                        key: ValueKey(line.item.id),
                        line: line,
                        controller: controller,
                      ),
                    ),
                ],
              );
            }),
            const SizedBox(height: AppSpacing.lg),
            Text('Status', style: AppTextStyles.label(color: AppColors.ink)),
            const SizedBox(height: AppSpacing.sm),
            _StatusDropdown(controller: controller),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: 'Discount amount (optional)',
              hint: '0',
              controller: controller.discountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: 'Notes (optional)',
              controller: controller.notesController,
            ),
            const SizedBox(height: AppSpacing.xl),
            _TotalsCard(controller: controller),
            const SizedBox(height: AppSpacing.lg),
            Obx(() {
              final error = controller.errorMessage.value;
              if (error == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Text(error, style: AppTextStyles.caption(color: AppColors.coral)),
              );
            }),
            Obx(
              () => PrimaryButton(
                label: 'Create order',
                isLoading: controller.isSaving.value,
                onPressed: controller.isSaving.value ? null : controller.create,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomerCard extends StatelessWidget {
  final OrderCreateController controller;
  const _CustomerCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final c = controller.customer;
    final subtitle = [
      if (c.zoneName.trim().isNotEmpty) c.zoneName.trim(),
      if (c.partyCode.trim().isNotEmpty) c.partyCode.trim(),
    ].join(' · ');
    return AppCard(
      child: Row(
        children: [
          const Icon(Icons.person_outline, color: AppColors.elaraBlue),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.name,
                  style: AppTextStyles.title().copyWith(fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTextStyles.label()),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyCart({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onAdd,
      child: Row(
        children: [
          const Icon(Icons.add_shopping_cart_outlined, color: AppColors.inkMuted),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'No products added yet. Tap to add one.',
              style: AppTextStyles.body(color: AppColors.inkMuted),
            ),
          ),
        ],
      ),
    );
  }
}

class _LineTile extends StatefulWidget {
  final OrderLine line;
  final OrderCreateController controller;

  const _LineTile({super.key, required this.line, required this.controller});

  @override
  State<_LineTile> createState() => _LineTileState();
}

class _LineTileState extends State<_LineTile> {
  late final TextEditingController _priceController;
  late final TextEditingController _emptyController;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(text: _fmt(widget.line.unitPrice));
    _emptyController = TextEditingController(text: '${widget.line.emptyReceived}');
  }

  String _fmt(double v) => v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  @override
  void dispose() {
    _priceController.dispose();
    _emptyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final line = widget.line;
    final c = widget.controller;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  line.item.itemName,
                  style: AppTextStyles.title().copyWith(fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: () => c.removeLine(line),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.delete_outline, size: 20, color: AppColors.coral),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Quantity stepper
              _Stepper(
                label: 'Qty',
                value: _fmt(line.quantity),
                onMinus: () => c.setQuantity(line, line.quantity - 1),
                onPlus: () => c.setQuantity(line, line.quantity + 1),
              ),
              const SizedBox(width: AppSpacing.md),
              // Unit price
              Expanded(
                child: _MiniField(
                  label: 'Unit price',
                  controller: _priceController,
                  onChanged: (v) => c.setUnitPrice(line, double.tryParse(v) ?? 0),
                ),
              ),
            ],
          ),
          if (line.item.isRefill) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _MiniField(
                    label: 'Empties received',
                    controller: _emptyController,
                    integer: true,
                    onChanged: (v) => c.setEmptyReceived(line, int.tryParse(v) ?? 0),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Obx(() {
            // Reacts to qty/price edits via the controller's refresh().
            c.lines.length; // touch for reactivity
            return Align(
              alignment: Alignment.centerRight,
              child: Text(
                'PKR ${_moneyFormat.format(line.lineAmount)}',
                style: AppTextStyles.tabular(
                  AppTextStyles.title().copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  const _Stepper({
    required this.label,
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption(color: AppColors.inkMuted)),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: AppColors.mist,
            borderRadius: BorderRadius.circular(AppRadius.button),
            border: Border.all(color: AppColors.line),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _stepBtn(Icons.remove, onMinus),
              Container(
                constraints: const BoxConstraints(minWidth: 34),
                alignment: Alignment.center,
                child: Text(value, style: AppTextStyles.tabular(AppTextStyles.body())),
              ),
              _stepBtn(Icons.add, onPlus),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stepBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.button),
      child: SizedBox(
        width: 40,
        height: 44,
        child: Icon(icon, size: 18, color: AppColors.elaraBlue),
      ),
    );
  }
}

class _MiniField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool integer;

  const _MiniField({
    required this.label,
    required this.controller,
    required this.onChanged,
    this.integer = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption(color: AppColors.inkMuted)),
        const SizedBox(height: 4),
        SizedBox(
          height: 44,
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            keyboardType: TextInputType.numberWithOptions(decimal: !integer),
            inputFormatters: integer ? [FilteringTextInputFormatter.digitsOnly] : null,
            style: AppTextStyles.body(),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.mist,
              contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.button),
                borderSide: const BorderSide(color: AppColors.line),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.button),
                borderSide: const BorderSide(color: AppColors.line),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.button),
                borderSide: const BorderSide(color: AppColors.elaraBlue, width: 1.6),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusDropdown extends StatelessWidget {
  final OrderCreateController controller;
  const _StatusDropdown({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.mist,
        borderRadius: BorderRadius.circular(AppRadius.button),
        border: Border.all(color: AppColors.line),
      ),
      child: Obx(
        () => DropdownButtonHideUnderline(
          child: DropdownButton<OrderStatus>(
            value: controller.status.value,
            isExpanded: true,
            onChanged: controller.setStatus,
            borderRadius: BorderRadius.circular(AppRadius.button),
            style: AppTextStyles.body(),
            items: [
              for (final s in OrderStatus.all)
                DropdownMenuItem(
                  value: s,
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(color: s.color, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(s.label),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TotalsCard extends StatelessWidget {
  final OrderCreateController controller;
  const _TotalsCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Obx(() {
        // Touch reactive sources so totals recompute on any edit.
        controller.lines.length;
        controller.discountAmount;
        return Column(
          children: [
            _row('Subtotal', controller.subtotal),
            if (controller.discountAmount > 0) ...[
              const SizedBox(height: AppSpacing.sm),
              _row('Discount', -controller.discountAmount, color: AppColors.coral),
            ],
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Divider(height: 1, color: AppColors.line),
            ),
            _row('Total', controller.total, bold: true),
          ],
        );
      }),
    );
  }

  Widget _row(String label, double value, {bool bold = false, Color? color}) {
    final style = bold
        ? AppTextStyles.title().copyWith(fontWeight: FontWeight.w700)
        : AppTextStyles.body(color: AppColors.inkMuted);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(
          'PKR ${_moneyFormat.format(value)}',
          style: AppTextStyles.tabular(style).copyWith(color: color),
        ),
      ],
    );
  }
}

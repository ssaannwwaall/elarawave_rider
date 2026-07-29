import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/order_status.dart';
import '../../core/network/api_exception.dart';
import '../../core/storage/session_storage.dart';
import '../../domain/entities/created_order.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/item.dart';
import '../../domain/repositories/rider_repository.dart';
import 'item_picker_controller.dart';
import 'item_picker_screen.dart';

/// One editable line in the order being built.
class OrderLine {
  final Item item;
  double quantity;
  double unitPrice;
  int emptyReceived;

  OrderLine({
    required this.item,
    this.quantity = 1,
    required this.unitPrice,
    this.emptyReceived = 0,
  });

  double get lineAmount => quantity * unitPrice;
}

class OrderCreateController extends GetxController {
  final RiderRepository _riderRepository = Get.find<RiderRepository>();
  final SessionStorage _sessionStorage = Get.find<SessionStorage>();

  /// The customer this order is for (passed via Get.arguments).
  final Customer customer;

  OrderCreateController({required this.customer});

  final RxList<OrderLine> lines = <OrderLine>[].obs;
  final Rx<OrderStatus> status = OrderStatus.ready.obs;

  final discountController = TextEditingController();
  final notesController = TextEditingController();

  final RxBool isSaving = false.obs;
  final RxnString errorMessage = RxnString();

  /// Mirror of the discount text field so totals recompute reactively.
  final RxDouble _discount = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    discountController.addListener(() {
      final v = double.tryParse(discountController.text.trim()) ?? 0;
      _discount.value = v < 0 ? 0 : v;
    });
  }

  double get discountAmount => _discount.value;

  double get subtotal => lines.fold(0.0, (sum, l) => sum + l.lineAmount);

  double get total {
    final t = subtotal - discountAmount;
    return t < 0 ? 0 : t;
  }

  Future<void> addItem() async {
    final item = await Get.to<Item>(
      () => const ItemPickerScreen(),
      binding: BindingsBuilder(() {
        Get.put(ItemPickerController());
      }),
    );
    if (item == null) return;

    // Already in the cart? Just bump the quantity.
    final existing = lines.firstWhereOrNull((l) => l.item.id == item.id);
    if (existing != null) {
      existing.quantity += 1;
      if (item.isRefill) existing.emptyReceived = existing.quantity.round();
      lines.refresh();
      return;
    }

    lines.add(OrderLine(
      item: item,
      quantity: 1,
      unitPrice: item.salePrice,
      emptyReceived: item.isRefill ? 1 : 0,
    ));
  }

  void setQuantity(OrderLine line, double quantity) {
    line.quantity = quantity < 1 ? 1 : quantity;
    // Keep empties in step with quantity for refill items until the rider
    // overrides it explicitly.
    if (line.item.isRefill && line.emptyReceived > line.quantity) {
      line.emptyReceived = line.quantity.round();
    }
    lines.refresh();
  }

  void setUnitPrice(OrderLine line, double price) {
    line.unitPrice = price < 0 ? 0 : price;
    lines.refresh();
  }

  void setEmptyReceived(OrderLine line, int empty) {
    line.emptyReceived = empty < 0 ? 0 : empty;
    lines.refresh();
  }

  void removeLine(OrderLine line) => lines.remove(line);

  void setStatus(OrderStatus? value) {
    if (value != null) status.value = value;
  }

  Future<void> create() async {
    final riderId = _sessionStorage.currentRider?.id;
    if (riderId == null) return;

    if (lines.isEmpty) {
      errorMessage.value = 'Add at least one item.';
      return;
    }

    final payload = lines
        .map((l) => <String, dynamic>{
              'product_id': l.item.id,
              'quantity': l.quantity,
              'unit_price': l.unitPrice,
              'empty_received': l.emptyReceived,
            })
        .toList();

    errorMessage.value = null;
    isSaving.value = true;
    try {
      final order = await _riderRepository.createOrder(
        riderId: riderId,
        customerId: customer.id,
        lines: payload,
        orderStatus: status.value.value,
        notes: notesController.text,
        discountAmount: discountAmount,
      );
      Get.back<CreatedOrder>(result: order);
      Get.snackbar('Order', 'Order ${order.orderNo} created.');
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (_) {
      errorMessage.value = 'Something went wrong. Please try again.';
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    discountController.dispose();
    notesController.dispose();
    super.onClose();
  }
}

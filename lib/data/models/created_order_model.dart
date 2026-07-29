import '../../domain/entities/created_order.dart';

double _dbl(dynamic v) =>
    v == null ? 0 : (v is num ? v.toDouble() : double.tryParse('$v') ?? 0);

int? _intOrNull(dynamic v) =>
    v == null ? null : (v is int ? v : int.tryParse('$v'));

bool _yesNo(dynamic v) {
  final s = v?.toString().trim().toLowerCase();
  return s == 'yes' || s == '1' || s == 'true';
}

class CreatedOrderModel extends CreatedOrder {
  const CreatedOrderModel({
    required super.id,
    super.orderNo,
    super.orderType,
    super.orderStatus,
    super.orderStatusLabel,
    super.orderDatetime,
    super.customerId,
    super.customerName,
    super.riderId,
    super.subtotal,
    super.discountAmount,
    super.taxAmount,
    super.totalAmount,
    super.notes,
    super.items,
  });

  factory CreatedOrderModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return CreatedOrderModel(
      id: _intOrNull(json['id']) ?? 0,
      orderNo: json['order_no']?.toString() ?? '',
      orderType: json['order_type']?.toString() ?? '',
      orderStatus: json['order_status']?.toString() ?? '',
      orderStatusLabel: json['order_status_label']?.toString() ?? '',
      orderDatetime: json['order_datetime']?.toString() ?? '',
      customerId: _intOrNull(json['customer_id']),
      customerName: json['customer_name']?.toString() ?? '',
      riderId: _intOrNull(json['rider_id']),
      subtotal: _dbl(json['subtotal']),
      discountAmount: _dbl(json['discount_amount']),
      taxAmount: _dbl(json['tax_amount']),
      totalAmount: _dbl(json['total_amount']),
      notes: json['notes']?.toString() ?? '',
      items: rawItems
          .whereType<Map<String, dynamic>>()
          .map((e) => CreatedOrderLine(
                productId: _intOrNull(e['product_id']),
                itemName: e['item_name']?.toString() ?? '',
                quantity: _dbl(e['quantity']),
                unitPrice: _dbl(e['unit_price']),
                lineAmount: _dbl(e['line_amount']),
                emptyReceived: _intOrNull(e['empty_received']) ?? 0,
                isRefill: _yesNo(e['is_refill']),
              ))
          .toList(),
    );
  }
}

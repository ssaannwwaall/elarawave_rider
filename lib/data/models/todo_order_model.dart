import '../../domain/entities/todo_order.dart';
import 'zone_model.dart';

num? _asNum(dynamic value) {
  if (value == null) return null;
  if (value is num) return value;
  return num.tryParse(value.toString());
}

int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse(value.toString());
}

double? _asDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

String? _asNonEmptyString(dynamic value) {
  final s = value?.toString().trim();
  return (s == null || s.isEmpty) ? null : s;
}

/// The backend sends "0000-00-00" as a null-placeholder for unset dates
/// rather than omitting the field. Treat it (and any unparseable value) as
/// "no date set".
DateTime? _parseBackendDate(dynamic value) {
  final s = value?.toString().trim();
  if (s == null || s.isEmpty || s.startsWith('0000-00-00')) return null;
  return DateTime.tryParse(s);
}

class OrderItemModel extends OrderItem {
  const OrderItemModel({
    super.id,
    super.productId,
    super.itemName,
    super.quantity,
    super.unitPrice,
    super.lineAmount,
    super.emptyReceived,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: _asInt(json['id']),
      productId: _asInt(json['product_id']),
      itemName: _asNonEmptyString(json['item_name']),
      quantity: _asNum(json['quantity']),
      unitPrice: _asNum(json['unit_price']),
      lineAmount: _asNum(json['line_amount']),
      emptyReceived: _asNum(json['empty_received']),
    );
  }
}

class OrderCustomerModel extends OrderCustomer {
  const OrderCustomerModel({
    super.id,
    super.partyCode,
    super.name,
    super.typeLabel,
    super.address,
    super.phone,
    super.latitude,
    super.longitude,
    super.lastDays,
    super.empty,
    super.balance,
  });

  factory OrderCustomerModel.fromJson(Map<String, dynamic> json) {
    return OrderCustomerModel(
      id: _asInt(json['id']),
      partyCode: _asNonEmptyString(json['party_code']),
      name: _asNonEmptyString(json['name']),
      typeLabel: _asNonEmptyString(json['type_label']),
      address: _asNonEmptyString(json['address']),
      phone: _asNonEmptyString(json['phone']),
      latitude: _asDouble(json['latitude']),
      longitude: _asDouble(json['longitude']),
      lastDays: _asInt(json['last_days']),
      empty: _asNum(json['empty']),
      balance: _asNum(json['balance']),
    );
  }
}

class ToDoOrderModel extends ToDoOrder {
  const ToDoOrderModel({
    super.sr,
    super.orderId,
    super.orderNo,
    super.orderType,
    super.orderStatus,
    super.orderStatusLabel,
    super.orderDatetime,
    super.deliveryDueDate,
    required super.amount,
    required super.received,
    super.notes,
    super.customer,
    super.zone,
    required super.items,
  });

  factory ToDoOrderModel.fromJson(Map<String, dynamic> json) {
    final customerJson = json['customer'] as Map<String, dynamic>?;
    final zoneJson = json['zone'] as Map<String, dynamic>?;
    final itemsJson = json['items'] as List<dynamic>? ?? [];

    return ToDoOrderModel(
      sr: _asInt(json['sr']),
      orderId: _asInt(json['order_id']),
      orderNo: _asNonEmptyString(json['order_no']),
      orderType: _asNonEmptyString(json['order_type']),
      orderStatus: _asNonEmptyString(json['order_status']),
      orderStatusLabel: _asNonEmptyString(json['order_status_label']),
      orderDatetime: _parseBackendDate(json['order_datetime']),
      deliveryDueDate: _parseBackendDate(json['delivery_due_date']),
      amount: _asNum(json['amount']) ?? 0,
      received: _asNum(json['received']) ?? 0,
      notes: _asNonEmptyString(json['notes']),
      customer: customerJson == null ? null : OrderCustomerModel.fromJson(customerJson),
      zone: zoneJson == null ? null : ZoneModel.fromJson(zoneJson),
      items: itemsJson
          .whereType<Map<String, dynamic>>()
          .map((e) => OrderItemModel.fromJson(e))
          .toList(),
    );
  }
}

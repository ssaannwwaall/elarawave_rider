import 'zone.dart';

/// A single line item within an order. See docs/API.md, section 4.3.
class OrderItem {
  final int? id;
  final int? productId;
  final String? itemName;
  final num? quantity;
  final num? unitPrice;
  final num? lineAmount;
  final num? emptyReceived;

  const OrderItem({
    this.id,
    this.productId,
    this.itemName,
    this.quantity,
    this.unitPrice,
    this.lineAmount,
    this.emptyReceived,
  });
}

/// Customer attached to an order. Fields are nullable/defensive because this
/// is only confirmed against a single sample record where several fields
/// (address, geo, phone) are effectively empty placeholders.
class OrderCustomer {
  final int? id;
  final String? partyCode;
  final String? name;
  final String? typeLabel;
  final String? address;
  final String? phone;
  final double? latitude;
  final double? longitude;
  final int? lastDays;
  final num? empty;
  final num? balance;

  const OrderCustomer({
    this.id,
    this.partyCode,
    this.name,
    this.typeLabel,
    this.address,
    this.phone,
    this.latitude,
    this.longitude,
    this.lastDays,
    this.empty,
    this.balance,
  });

  bool get hasAddress => address != null && address!.trim().isNotEmpty;

  bool get hasLocation => latitude != null && longitude != null;

  /// Guards against placeholder values like "+92" with no actual subscriber
  /// number attached — a real PK mobile number carries at least 10 digits.
  bool get hasValidPhone =>
      phone != null && RegExp(r'\d').allMatches(phone!).length >= 10;
}

class ToDoOrder {
  final int? sr;
  final int? orderId;
  final String? orderNo;
  /// Open string, e.g. "sale_order" — only one value confirmed so far, do
  /// not treat as a closed enum.
  final String? orderType;
  /// Machine-readable status key, e.g. "ready". Only this value is
  /// confirmed; more (delivered/cancelled/pending/etc.) will arrive later.
  final String? orderStatus;
  /// Human-readable label for [orderStatus], e.g. "Ready".
  final String? orderStatusLabel;
  final DateTime? orderDatetime;
  /// Null when the backend sends its "unset" placeholder ("0000-00-00").
  final DateTime? deliveryDueDate;
  final num amount;
  final num received;
  final String? notes;
  final OrderCustomer? customer;
  final Zone? zone;
  final List<OrderItem> items;

  const ToDoOrder({
    this.sr,
    this.orderId,
    this.orderNo,
    this.orderType,
    this.orderStatus,
    this.orderStatusLabel,
    this.orderDatetime,
    this.deliveryDueDate,
    required this.amount,
    required this.received,
    this.notes,
    this.customer,
    this.zone,
    required this.items,
  });

  num get outstanding {
    final diff = amount - received;
    return diff < 0 ? 0 : diff;
  }

  bool get isFullyReceived => received >= amount;
}

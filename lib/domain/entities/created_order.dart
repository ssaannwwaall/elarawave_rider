/// The order returned by `order_create`.
class CreatedOrder {
  final int id;
  final String orderNo;
  final String orderType;
  final String orderStatus;
  final String orderStatusLabel;
  final String orderDatetime;
  final int? customerId;
  final String customerName;
  final int? riderId;
  final double subtotal;
  final double discountAmount;
  final double taxAmount;
  final double totalAmount;
  final String notes;
  final List<CreatedOrderLine> items;

  const CreatedOrder({
    required this.id,
    this.orderNo = '',
    this.orderType = '',
    this.orderStatus = '',
    this.orderStatusLabel = '',
    this.orderDatetime = '',
    this.customerId,
    this.customerName = '',
    this.riderId,
    this.subtotal = 0,
    this.discountAmount = 0,
    this.taxAmount = 0,
    this.totalAmount = 0,
    this.notes = '',
    this.items = const [],
  });
}

class CreatedOrderLine {
  final int? productId;
  final String itemName;
  final double quantity;
  final double unitPrice;
  final double lineAmount;
  final int emptyReceived;
  final bool isRefill;

  const CreatedOrderLine({
    this.productId,
    this.itemName = '',
    this.quantity = 0,
    this.unitPrice = 0,
    this.lineAmount = 0,
    this.emptyReceived = 0,
    this.isRefill = false,
  });
}

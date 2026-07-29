/// Result of an `update_order_status` call — the order's new status plus the
/// status it moved from, so the UI can confirm the transition.
class OrderStatusUpdate {
  final int? orderId;
  final String? orderNo;
  final String? orderType;
  final String? orderStatus;
  final String? orderStatusLabel;
  final String? previousStatus;
  final String? previousStatusLabel;

  const OrderStatusUpdate({
    this.orderId,
    this.orderNo,
    this.orderType,
    this.orderStatus,
    this.orderStatusLabel,
    this.previousStatus,
    this.previousStatusLabel,
  });

  /// True when the new status differs from the one it replaced.
  bool get didChange =>
      previousStatus != null && orderStatus != null && previousStatus != orderStatus;
}

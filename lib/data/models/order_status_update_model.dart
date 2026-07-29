import '../../domain/entities/order_status_update.dart';

class OrderStatusUpdateModel extends OrderStatusUpdate {
  const OrderStatusUpdateModel({
    super.orderId,
    super.orderNo,
    super.orderType,
    super.orderStatus,
    super.orderStatusLabel,
    super.previousStatus,
    super.previousStatusLabel,
  });

  factory OrderStatusUpdateModel.fromJson(Map<String, dynamic> json) {
    String? str(dynamic v) {
      final s = v?.toString().trim();
      return (s == null || s.isEmpty) ? null : s;
    }

    return OrderStatusUpdateModel(
      orderId: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}'),
      orderNo: str(json['order_no']),
      orderType: str(json['order_type']),
      orderStatus: str(json['order_status']),
      orderStatusLabel: str(json['order_status_label']),
      previousStatus: str(json['previous_status']),
      previousStatusLabel: str(json['previous_status_label']),
    );
  }
}

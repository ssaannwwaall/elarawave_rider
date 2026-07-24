import '../../domain/entities/todo_list.dart';
import 'todo_order_model.dart';

class ToDoSummaryModel extends ToDoSummary {
  const ToDoSummaryModel({required super.count, required super.sold, required super.cash});

  factory ToDoSummaryModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ToDoSummaryModel(count: 0, sold: 0, cash: 0);
    return ToDoSummaryModel(
      count: json['count'] is int ? json['count'] as int : int.tryParse('${json['count']}') ?? 0,
      sold: json['sold'] is num ? json['sold'] as num : num.tryParse('${json['sold']}') ?? 0,
      cash: json['cash'] is num ? json['cash'] as num : num.tryParse('${json['cash']}') ?? 0,
    );
  }
}

class ToDoListModel extends ToDoList {
  const ToDoListModel({
    required super.listType,
    required super.date,
    required super.filterZoneId,
    required super.filterQuery,
    required super.summary,
    required super.orders,
  });

  factory ToDoListModel.fromJson(Map<String, dynamic> json) {
    final filters = json['filters'] as Map<String, dynamic>?;
    final ordersJson = json['orders'] as List<dynamic>? ?? [];
    return ToDoListModel(
      listType: json['list_type']?.toString() ?? 'today',
      date: json['date']?.toString() ?? '',
      filterZoneId: filters?['zone_id'] is int
          ? filters!['zone_id'] as int
          : int.tryParse('${filters?['zone_id']}') ?? 0,
      filterQuery: filters?['q']?.toString() ?? '',
      summary: ToDoSummaryModel.fromJson(json['summary'] as Map<String, dynamic>?),
      orders: ordersJson
          .whereType<Map<String, dynamic>>()
          .map((e) => ToDoOrderModel.fromJson(e))
          .toList(),
    );
  }
}

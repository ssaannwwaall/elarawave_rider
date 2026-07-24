import 'todo_order.dart';

class ToDoSummary {
  final int count;
  final num sold;
  final num cash;

  const ToDoSummary({required this.count, required this.sold, required this.cash});

  const ToDoSummary.empty() : count = 0, sold = 0, cash = 0;
}

class ToDoList {
  final String listType;
  final String date;
  final int filterZoneId;
  final String filterQuery;
  final ToDoSummary summary;
  final List<ToDoOrder> orders;

  const ToDoList({
    required this.listType,
    required this.date,
    required this.filterZoneId,
    required this.filterQuery,
    required this.summary,
    required this.orders,
  });
}

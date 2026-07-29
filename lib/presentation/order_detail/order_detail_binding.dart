import 'package:get/get.dart';
import '../../domain/entities/todo_order.dart';
import 'order_detail_controller.dart';

class OrderDetailBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments;
    Get.put(
      OrderDetailController(order: args is ToDoOrder ? args : null),
    );
  }
}

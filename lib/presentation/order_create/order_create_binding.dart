import 'package:get/get.dart';
import '../../domain/entities/customer.dart';
import 'order_create_controller.dart';

class OrderCreateBinding extends Bindings {
  @override
  void dependencies() {
    final customer = Get.arguments as Customer;
    Get.put(OrderCreateController(customer: customer));
  }
}

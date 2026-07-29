import 'package:get/get.dart';
import 'customer_create_controller.dart';

class CustomerCreateBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(CustomerCreateController());
  }
}

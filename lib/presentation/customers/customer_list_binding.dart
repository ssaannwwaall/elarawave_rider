import 'package:get/get.dart';
import 'customer_list_controller.dart';

class CustomerListBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(CustomerListController());
  }
}

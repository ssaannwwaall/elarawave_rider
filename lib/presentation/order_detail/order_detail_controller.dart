import 'package:get/get.dart';
import '../../core/constants/order_status.dart';
import '../../core/network/api_exception.dart';
import '../../core/storage/session_storage.dart';
import '../../domain/entities/todo_order.dart';
import '../../domain/repositories/rider_repository.dart';
import '../home/home_controller.dart';
import 'widgets/order_delivered_dialog.dart';

class OrderDetailController extends GetxController {
  final RiderRepository _riderRepository = Get.find<RiderRepository>();
  final SessionStorage _sessionStorage = Get.find<SessionStorage>();

  final ToDoOrder? order;

  OrderDetailController({this.order});

  final RxnString statusKey = RxnString();
  final RxnString statusLabel = RxnString();

  final RxBool isUpdating = false.obs;
  final RxnString errorMessage = RxnString();

  /// Set to true once a status change succeeds, so Home knows to refresh.
  bool didUpdateStatus = false;

  @override
  void onInit() {
    super.onInit();
    statusKey.value = order?.orderStatus;
    statusLabel.value = order?.orderStatusLabel ?? OrderStatus.labelFor(order?.orderStatus);
  }

  Future<void> changeStatus(OrderStatus status) async {
    final riderId = _sessionStorage.currentRider?.id;
    final orderId = order?.orderId;
    if (riderId == null || orderId == null) return;
    if (status.value == statusKey.value) return; // no-op

    errorMessage.value = null;
    isUpdating.value = true;
    try {
      final result = await _riderRepository.updateOrderStatus(
        riderId: riderId,
        orderId: orderId,
        orderStatus: status.value,
      );
      statusKey.value = result.orderStatus ?? status.value;
      statusLabel.value = result.orderStatusLabel ?? status.label;
      didUpdateStatus = true;
      // Keep the Home to-do list in sync with the new status.
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().refreshData();
      }

      // Reaching "delivered" completes the order — celebrate it and return
      // the rider to the (freshly refreshed) home list.
      if ((result.orderStatus ?? status.value) == OrderStatus.delivered.value) {
        _showDeliveredDialog();
      } else {
        Get.snackbar(
          'Order updated',
          'Status changed to ${statusLabel.value}.',
        );
      }
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      Get.snackbar('Update failed', e.message);
    } catch (_) {
      errorMessage.value = 'Something went wrong. Please try again.';
      Get.snackbar('Update failed', errorMessage.value!);
    } finally {
      isUpdating.value = false;
    }
  }

  void _showDeliveredDialog() {
    final label = order?.orderNo != null
        ? '#${order!.orderNo}'
        : (order?.orderId != null ? '#${order!.orderId}' : null);
    Get.dialog(
      OrderDeliveredDialog(
        orderLabel: label,
        onDone: () {
          Get.back(); // close the dialog
          Get.back(); // pop the detail screen back to home
        },
      ),
      barrierDismissible: false,
    );
  }
}

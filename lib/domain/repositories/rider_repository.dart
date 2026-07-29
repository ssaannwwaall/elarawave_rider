import '../entities/rider.dart';
import '../entities/zone.dart';
import '../entities/todo_list.dart';
import '../entities/order_status_update.dart';
import '../entities/customer.dart';
import '../entities/item.dart';
import '../entities/created_order.dart';

abstract class RiderRepository {
  Future<Rider> login({required String username, required String password});

  Future<List<Allocation>> getAllocatedZones({required int riderId});

  Future<OrderStatusUpdate> updateOrderStatus({
    required int riderId,
    required int orderId,
    required String orderStatus,
  });

  Future<Rider> getProfile({required int riderId});

  Future<Rider> updateProfile({
    required int riderId,
    required String name,
    required String email,
    required String username,
    String? password,
    String? photoPath,
  });

  /// [date] is accepted today for forward-compatibility with the date tabs
  /// on Home, but the live API does not yet accept a date parameter — see
  /// docs/API.md "Known gap". It is currently unused by the data layer.
  Future<ToDoList> getToDoList({
    required int riderId,
    DateTime? date,
    int? zoneId,
    String? query,
  });

  Future<CustomerPage> getCustomers({
    required int riderId,
    String? query,
    int? zoneId,
    int page,
    int perPage,
  });

  Future<Customer> createCustomer({
    required int riderId,
    required String name,
    String? phone,
    String? phoneCountryCode,
    String? address,
    String? email,
    int? zoneId,
    double? latitude,
    double? longitude,
    double? openingBalance,
  });

  Future<ItemPage> getItems({
    required int riderId,
    String? query,
    String? itemType,
    int page,
    int perPage,
  });

  Future<CreatedOrder> createOrder({
    required int riderId,
    required int customerId,
    required List<Map<String, dynamic>> lines,
    String orderType,
    String? orderStatus,
    String? notes,
    double? discountAmount,
  });
}

import '../../domain/entities/rider.dart';
import '../../domain/entities/zone.dart';
import '../../domain/entities/todo_list.dart';
import '../../domain/entities/order_status_update.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/item.dart';
import '../../domain/entities/created_order.dart';
import '../../domain/repositories/rider_repository.dart';
import '../datasources/rider_remote_datasource.dart';

class RiderRepositoryImpl implements RiderRepository {
  final RiderRemoteDataSource _remoteDataSource;

  RiderRepositoryImpl(this._remoteDataSource);

  @override
  Future<Rider> login({required String username, required String password}) {
    return _remoteDataSource.login(username: username, password: password);
  }

  @override
  Future<List<Allocation>> getAllocatedZones({required int riderId}) {
    return _remoteDataSource.fetchAllocatedZones(riderId: riderId);
  }

  @override
  Future<ToDoList> getToDoList({
    required int riderId,
    DateTime? date,
    int? zoneId,
    String? query,
  }) {
    return _remoteDataSource.fetchToDoList(
      riderId: riderId,
      date: date,
      zoneId: zoneId,
      query: query,
    );
  }

  @override
  Future<OrderStatusUpdate> updateOrderStatus({
    required int riderId,
    required int orderId,
    required String orderStatus,
  }) {
    return _remoteDataSource.updateOrderStatus(
      riderId: riderId,
      orderId: orderId,
      orderStatus: orderStatus,
    );
  }

  @override
  Future<Rider> getProfile({required int riderId}) {
    return _remoteDataSource.fetchProfile(riderId: riderId);
  }

  @override
  Future<Rider> updateProfile({
    required int riderId,
    required String name,
    required String email,
    required String username,
    String? password,
    String? photoPath,
  }) {
    return _remoteDataSource.updateProfile(
      riderId: riderId,
      name: name,
      email: email,
      username: username,
      password: password,
      photoPath: photoPath,
    );
  }

  @override
  Future<CustomerPage> getCustomers({
    required int riderId,
    String? query,
    int? zoneId,
    int page = 1,
    int perPage = 50,
  }) {
    return _remoteDataSource.fetchCustomers(
      riderId: riderId,
      query: query,
      zoneId: zoneId,
      page: page,
      perPage: perPage,
    );
  }

  @override
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
  }) {
    return _remoteDataSource.createCustomer(
      riderId: riderId,
      name: name,
      phone: phone,
      phoneCountryCode: phoneCountryCode,
      address: address,
      email: email,
      zoneId: zoneId,
      latitude: latitude,
      longitude: longitude,
      openingBalance: openingBalance,
    );
  }

  @override
  Future<ItemPage> getItems({
    required int riderId,
    String? query,
    String? itemType,
    int page = 1,
    int perPage = 100,
  }) {
    return _remoteDataSource.fetchItems(
      riderId: riderId,
      query: query,
      itemType: itemType,
      page: page,
      perPage: perPage,
    );
  }

  @override
  Future<CreatedOrder> createOrder({
    required int riderId,
    required int customerId,
    required List<Map<String, dynamic>> lines,
    String orderType = 'sale',
    String? orderStatus,
    String? notes,
    double? discountAmount,
  }) {
    return _remoteDataSource.createOrder(
      riderId: riderId,
      customerId: customerId,
      lines: lines,
      orderType: orderType,
      orderStatus: orderStatus,
      notes: notes,
      discountAmount: discountAmount,
    );
  }
}

import 'dart:convert';

import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../models/rider_model.dart';
import '../models/zone_model.dart';
import '../models/todo_list_model.dart';
import '../models/order_status_update_model.dart';
import '../models/customer_model.dart';
import '../models/item_model.dart';
import '../models/created_order_model.dart';

class RiderRemoteDataSource {
  final ApiClient _apiClient;

  RiderRemoteDataSource(this._apiClient);

  Future<RiderModel> login({required String username, required String password}) async {
    final response = await _apiClient.get('login', queryParameters: {
      'device': 'app',
      'username': username,
      'password': password,
    });

    if (response['success'] != true) {
      throw ApiException(response['message']?.toString() ?? 'Login failed.');
    }

    final riderJson = response['rider'] as Map<String, dynamic>?;
    if (riderJson == null) {
      throw const ApiException('Login succeeded but no rider data was returned.');
    }
    return RiderModel.fromJson(riderJson);
  }

  Future<List<AllocationModel>> fetchAllocatedZones({required int riderId}) async {
    final response = await _apiClient.get('allocated_zones', queryParameters: {
      'rider_id': riderId,
    });

    if (response['success'] != true) {
      throw ApiException(response['message']?.toString() ?? 'Could not load zones.');
    }

    final allocations = response['allocations'] as List<dynamic>? ?? [];
    return allocations
        .whereType<Map<String, dynamic>>()
        .map((e) => AllocationModel.fromJson(e))
        .toList();
  }

  /// [date], [zoneId], [query] are accepted for forward-compatibility with
  /// the Home screen's date tabs/zone filter/search bar, but the live API
  /// only documents `rider_id` today (docs/API.md "Known gap"). Wiring the
  /// remaining params through is a one-line change once confirmed.
  Future<ToDoListModel> fetchToDoList({
    required int riderId,
    DateTime? date,
    int? zoneId,
    String? query,
  }) async {
    final response = await _apiClient.get('todo_list', queryParameters: {
      'rider_id': riderId,
    });

    if (response['success'] != true) {
      throw ApiException(response['message']?.toString() ?? 'Could not load the to-do list.');
    }

    return ToDoListModel.fromJson(response);
  }

  /// Moves an order to [orderStatus] (one of the wire values in
  /// `OrderStatus`). Returns the resulting status transition.
  Future<OrderStatusUpdateModel> updateOrderStatus({
    required int riderId,
    required int orderId,
    required String orderStatus,
  }) async {
    final response = await _apiClient.get('update_order_status', queryParameters: {
      'device': 'app',
      'rider_id': riderId,
      'order_id': orderId,
      'order_status': orderStatus,
    });

    if (response['success'] != true) {
      throw ApiException(response['message']?.toString() ?? 'Could not update the order status.');
    }

    final orderJson = response['order'] as Map<String, dynamic>?;
    if (orderJson == null) {
      throw const ApiException('Status updated but no order data was returned.');
    }
    return OrderStatusUpdateModel.fromJson(orderJson);
  }

  Future<RiderModel> fetchProfile({required int riderId}) async {
    final response = await _apiClient.get('profile', queryParameters: {
      'device': 'app',
      'rider_id': riderId,
    });

    if (response['success'] != true) {
      throw ApiException(response['message']?.toString() ?? 'Could not load the profile.');
    }

    final riderJson = response['rider'] as Map<String, dynamic>?;
    if (riderJson == null) {
      throw const ApiException('Profile loaded but no rider data was returned.');
    }
    return RiderModel.fromJson(riderJson);
  }

  /// Updates the rider's profile. [password] and [photoPath] are optional —
  /// omit/leave null to keep the current password / photo unchanged.
  Future<RiderModel> updateProfile({
    required int riderId,
    required String name,
    required String email,
    required String username,
    String? password,
    String? photoPath,
  }) async {
    final response = await _apiClient.postForm(
      'update_profile',
      queryParameters: {'device': 'app'},
      fields: {
        'rider_id': riderId,
        'name': name,
        'email': email,
        'username': username,
        if (password != null && password.isNotEmpty) 'password': password,
      },
      files: {'photo': photoPath},
    );

    if (response['success'] != true) {
      throw ApiException(response['message']?.toString() ?? 'Could not update the profile.');
    }

    final riderJson = response['rider'] as Map<String, dynamic>?;
    if (riderJson == null) {
      throw const ApiException('Profile updated but no rider data was returned.');
    }
    return RiderModel.fromJson(riderJson);
  }

  /// Lists the rider's customers. [query] searches name/code/phone/address,
  /// [zoneId] filters to an allocated zone. [page]/[perPage] paginate
  /// (per_page is capped at 100 by the backend).
  Future<CustomerPageModel> fetchCustomers({
    required int riderId,
    String? query,
    int? zoneId,
    int page = 1,
    int perPage = 50,
  }) async {
    final response = await _apiClient.get('customer_list', queryParameters: {
      'device': 'app',
      'rider_id': riderId,
      if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
      if (zoneId != null) 'zone_id': zoneId,
      'page': page,
      'per_page': perPage,
    });

    if (response['success'] != true) {
      throw ApiException(response['message']?.toString() ?? 'Could not load customers.');
    }

    return CustomerPageModel.fromJson(response);
  }

  /// Creates a customer for [riderId]. Only [name] is required; the rest are
  /// optional. [zoneId] must be one allocated to the rider when the rider has
  /// zones. [phoneCountryCode] defaults to +92 server-side.
  Future<CustomerModel> createCustomer({
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
  }) async {
    final response = await _apiClient.postForm(
      'customer_create',
      queryParameters: {'device': 'app'},
      fields: {
        'rider_id': riderId,
        'name': name,
        if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
        if (phoneCountryCode != null && phoneCountryCode.trim().isNotEmpty)
          'phone_country_code': phoneCountryCode.trim(),
        if (address != null && address.trim().isNotEmpty) 'address': address.trim(),
        if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
        if (zoneId != null) 'zone_id': zoneId,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (openingBalance != null) 'opening_balance': openingBalance,
      },
    );

    if (response['success'] != true) {
      throw ApiException(response['message']?.toString() ?? 'Could not create the customer.');
    }

    final customerJson = response['customer'] as Map<String, dynamic>?;
    if (customerJson == null) {
      throw const ApiException('Customer created but no data was returned.');
    }
    return CustomerModel.fromJson(customerJson);
  }

  /// Lists the company's sellable products. [query] searches item name /
  /// barcode; [itemType] filters to `finished_good` or `trade_item`.
  Future<ItemPageModel> fetchItems({
    required int riderId,
    String? query,
    String? itemType,
    int page = 1,
    int perPage = 100,
  }) async {
    final response = await _apiClient.get('items_list', queryParameters: {
      'device': 'app',
      'rider_id': riderId,
      if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
      if (itemType != null && itemType.isNotEmpty) 'item_type': itemType,
      'page': page,
      'per_page': perPage,
    });

    if (response['success'] != true) {
      throw ApiException(response['message']?.toString() ?? 'Could not load items.');
    }

    return ItemPageModel.fromJson(response);
  }

  /// Creates an order for [customerId] on behalf of [riderId]. [lines] is the
  /// list of line items sent as a JSON string in the `items` field. Each map
  /// must carry `product_id` and `quantity` (and optionally `unit_price` /
  /// `empty_received`).
  Future<CreatedOrderModel> createOrder({
    required int riderId,
    required int customerId,
    required List<Map<String, dynamic>> lines,
    String orderType = 'sale',
    String? orderStatus,
    String? notes,
    double? discountAmount,
  }) async {
    final response = await _apiClient.postForm(
      'order_create',
      queryParameters: {'device': 'app'},
      fields: {
        'rider_id': riderId,
        'customer_id': customerId,
        'order_type': orderType,
        'items': jsonEncode(lines),
        if (orderStatus != null && orderStatus.isNotEmpty) 'order_status': orderStatus,
        if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
        if (discountAmount != null && discountAmount > 0) 'discount_amount': discountAmount,
      },
    );

    if (response['success'] != true) {
      throw ApiException(response['message']?.toString() ?? 'Could not create the order.');
    }

    final orderJson = response['order'] as Map<String, dynamic>?;
    if (orderJson == null) {
      throw const ApiException('Order created but no data was returned.');
    }
    return CreatedOrderModel.fromJson(orderJson);
  }
}

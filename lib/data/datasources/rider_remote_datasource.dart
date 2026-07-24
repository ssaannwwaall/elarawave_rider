import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../models/rider_model.dart';
import '../models/zone_model.dart';
import '../models/todo_list_model.dart';

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
}

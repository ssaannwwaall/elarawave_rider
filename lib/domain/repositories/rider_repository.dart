import '../entities/rider.dart';
import '../entities/zone.dart';
import '../entities/todo_list.dart';

abstract class RiderRepository {
  Future<Rider> login({required String username, required String password});

  Future<List<Allocation>> getAllocatedZones({required int riderId});

  /// [date] is accepted today for forward-compatibility with the date tabs
  /// on Home, but the live API does not yet accept a date parameter — see
  /// docs/API.md "Known gap". It is currently unused by the data layer.
  Future<ToDoList> getToDoList({
    required int riderId,
    DateTime? date,
    int? zoneId,
    String? query,
  });
}

import '../../domain/entities/rider.dart';
import '../../domain/entities/zone.dart';
import '../../domain/entities/todo_list.dart';
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
}

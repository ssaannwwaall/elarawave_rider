import 'package:get_storage/get_storage.dart';
import '../../data/models/rider_model.dart';
import '../../domain/entities/rider.dart';

/// TEMPORARY: no auth token endpoint exists yet (docs/API.md, Pending/TBD).
/// Once the API returns a token, replace this raw rider-object storage with
/// token-based session handling (store token, attach as an Authorization
/// header in ApiClient, add a real logout call).
class SessionStorage {
  static const String _riderKey = 'rider';
  static const String _companyKey = 'company';

  final GetStorage _box;

  SessionStorage(this._box);

  /// The company slug used to build the API base URL (e.g. "demo").
  /// Deliberately preserved across logout so the login screen can prefill it.
  String get company => (_box.read(_companyKey) as String?)?.trim() ?? '';

  Future<void> saveCompany(String company) async {
    await _box.write(_companyKey, company.trim());
  }

  Rider? get currentRider {
    final json = _box.read(_riderKey);
    if (json == null) return null;
    return RiderModel.fromJson(Map<String, dynamic>.from(json));
  }

  bool get hasSession => currentRider != null;

  Future<void> saveRider(Rider rider) async {
    final model = rider is RiderModel
        ? rider
        : RiderModel(
            id: rider.id,
            name: rider.name,
            username: rider.username,
            email: rider.email,
            type: rider.type,
            photoUrl: rider.photoUrl,
          );
    await _box.write(_riderKey, model.toJson());
  }

  Future<void> clear() async {
    await _box.remove(_riderKey);
  }
}

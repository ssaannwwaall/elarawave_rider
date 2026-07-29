import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../network/api_client.dart';
import '../storage/session_storage.dart';
import '../theme/motion_config.dart';
import '../../data/datasources/rider_remote_datasource.dart';
import '../../data/repositories/rider_repository_impl.dart';
import '../../domain/repositories/rider_repository.dart';

/// Registers app-wide singletons once, before any route bindings run, so
/// every feature binding can `Get.find()` them without re-instantiating.
///
/// These survive `Get.deleteAll()` on logout (see HomeController.logout) —
/// only feature controllers holding rider-specific state get cleared.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Storage first — the ApiClient needs the saved company slug to build its
    // base URL on a warm start (an already-logged-in rider).
    final sessionStorage = Get.put(SessionStorage(GetStorage()), permanent: true);
    Get.put(ApiClient(company: sessionStorage.company), permanent: true);
    Get.put(RiderRemoteDataSource(Get.find<ApiClient>()), permanent: true);
    Get.put<RiderRepository>(
      RiderRepositoryImpl(Get.find<RiderRemoteDataSource>()),
      permanent: true,
    );
    Get.put(MotionConfig(), permanent: true);
  }
}

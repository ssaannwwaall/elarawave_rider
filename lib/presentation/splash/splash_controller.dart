import 'dart:async';
import 'package:get/get.dart';
import '../../core/routes/app_routes.dart';
import '../../core/storage/session_storage.dart';

class SplashController extends GetxController {
  final SessionStorage _sessionStorage = Get.find<SessionStorage>();

  final RxDouble fillProgress = 0.0.obs;

  static const _minDisplay = Duration(milliseconds: 2000);
  static const _maxDisplay = Duration(milliseconds: 3500);

  @override
  void onReady() {
    super.onReady();
    fillProgress.value = 1.0; // WaveFill animates its own transition to this target
    _decideNextRoute();
  }

  Future<void> _decideNextRoute() async {
    final stopwatch = Stopwatch()..start();

    // The session read is effectively instant (GetStorage is in-memory
    // after init), but this is guarded with a hard cap regardless — a rider
    // should never be trapped on a splash screen by a slow storage read.
    final hasSession = await Future<bool>(() => _sessionStorage.hasSession)
        .timeout(_maxDisplay, onTimeout: () => _sessionStorage.hasSession);

    final elapsed = stopwatch.elapsed;
    final remaining = _minDisplay - elapsed;
    if (remaining > Duration.zero) {
      await Future.delayed(remaining);
    }

    Get.offAllNamed(hasSession ? AppRoutes.home : AppRoutes.login);
  }
}

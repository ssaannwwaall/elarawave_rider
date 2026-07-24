import 'package:get/get.dart';

/// Single switch for every water animation in the app (shader, bubbles,
/// wave fills, purity ripples, entrance staggers). Flip [reduceMotion] to
/// true and every water widget renders its static fallback instead —
/// nothing in the layout breaks, effects just stop moving.
///
/// Honours the platform "reduce motion" accessibility setting automatically
/// (see [syncWithPlatform]); riders can also toggle it manually if a device
/// can't sustain the frame budget — see docs/ANIMATION.md.
class MotionConfig extends GetxController {
  final RxBool reduceMotion = false.obs;

  bool get motionEnabled => !reduceMotion.value;

  void syncWithPlatform(bool platformDisablesAnimations) {
    if (platformDisablesAnimations) {
      reduceMotion.value = true;
    }
  }

  void toggle() => reduceMotion.value = !reduceMotion.value;
}

/// Frame-time budget referenced by water widgets that self-degrade. See
/// docs/ANIMATION.md — kept as a named constant rather than scattered
/// magic numbers.
const Duration kFrameBudget = Duration(milliseconds: 20);

/// Convenience accessor so widgets don't each do `Get.find<MotionConfig>()`.
MotionConfig get motion => Get.find<MotionConfig>();

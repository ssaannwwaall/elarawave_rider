import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/elara_logo.dart';
import 'splash_controller.dart';
import 'widgets/animated_water_bottle.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SplashController>();
    final bottleSize = MediaQuery.sizeOf(context).width * 0.92;

    return Scaffold(
      backgroundColor: AppColors.snow,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo gently settles in, then keeps a soft breathing pulse —
              // the mark itself carries water droplets, so it reads as the
              // source the drops below fall from.
              const ElaraLogo(size: 104, showWordmark: false)
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .scale(begin: const Offset(0.85, 0.85), end: const Offset(1, 1), duration: 600.ms, curve: Curves.easeOutBack)
                  .then()
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .moveY(begin: 0, end: -4, duration: 1600.ms, curve: Curves.easeInOut),
              // Water drips off the logo and falls down into the bottle mouth.
              const _FallingDrops(),
              // The real product photo IS the water — a live splash, glass,
              // lemon and minerals on pure white. Shown large so it reads as
              // "fresh, cold, drink me", with a slow animated fill inside the
              // bottle body for a touch of live motion.
              Obx(() => AnimatedWaterBottle(
                    progress: controller.fillProgress.value,
                    size: bottleSize,
                  )),
              const SizedBox(height: 8),
              const _WordmarkFadeUp(),
            ],
          ),
        ),
      ),
    );
  }
}

/// A few water droplets that repeatedly fall from the logo down toward the
/// bottle mouth — the logo's own drops "dripping" into the bottle. Staggered
/// so they trickle rather than fall in unison.
class _FallingDrops extends StatelessWidget {
  const _FallingDrops();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      width: 90,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          _drop(dx: -16, delay: 0.ms),
          _drop(dx: 2, delay: 650.ms),
          _drop(dx: 15, delay: 1200.ms),
        ],
      ),
    );
  }

  Widget _drop({required double dx, required Duration delay}) {
    return Align(
      alignment: Alignment.topCenter,
      child: Transform.translate(
        offset: Offset(dx, 0),
        child: const Icon(Icons.water_drop, size: 13, color: AppColors.aqua)
            .animate(onPlay: (c) => c.repeat())
            .fadeIn(delay: delay, duration: 200.ms)
            .moveY(begin: -2, end: 46, delay: delay, duration: 1500.ms, curve: Curves.easeInQuad)
            .fadeOut(delay: delay + 1150.ms, duration: 350.ms),
      ),
    );
  }
}

class _WordmarkFadeUp extends StatelessWidget {
  const _WordmarkFadeUp();

  @override
  Widget build(BuildContext context) {
    return const ElaraLogo(showIcon: false, showWordmark: true)
        .animate()
        .fadeIn(delay: 900.ms, duration: 500.ms)
        .slideY(begin: 0.15, end: 0, delay: 900.ms, duration: 500.ms, curve: Curves.easeOutCubic);
  }
}

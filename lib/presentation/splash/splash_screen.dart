import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/elara_logo.dart';
import '../widgets/water/liquid_caustics_background.dart';
import 'splash_controller.dart';
import 'widgets/animated_water_bottle.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SplashController>();

    return Scaffold(
      body: LiquidCausticsBackground(
        colorDeep: AppColors.abyss,
        colorLight: AppColors.elaraBlue,
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const ElaraLogo(size: 48, showWordmark: false),
                const SizedBox(height: 20),
                Obx(() => AnimatedWaterBottle(progress: controller.fillProgress.value)),
                const SizedBox(height: 20),
                const _WordmarkFadeUp(),
              ],
            ),
          ),
        ),
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

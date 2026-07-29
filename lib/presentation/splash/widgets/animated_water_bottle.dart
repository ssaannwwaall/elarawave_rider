import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/water/wave_fill.dart';

/// The real Elara Wave bottle render (assets/brand/bottle-premium.png,
/// downloaded from elarawave.com) with an animated water level overlaid
/// directly onto the bottle's own body — not a hand-drawn silhouette.
///
/// The body rect below was measured directly against the source image (a
/// 500×500 square) via a grid overlay during development: the bottle's
/// visible plastic body spans roughly x:236–388, y:95–462 out of 500.
class AnimatedWaterBottle extends StatelessWidget {
  final double progress;
  final double size;

  const AnimatedWaterBottle({super.key, required this.progress, this.size = 260});

  static const double _left = 236 / 500;
  static const double _right = 388 / 500;
  static const double _top = 95 / 500;
  static const double _bottom = 462 / 500;

  @override
  Widget build(BuildContext context) {
    final bodyLeft = size * _left;
    final bodyTop = size * _top;
    final bodyWidth = size * (_right - _left);
    final bodyHeight = size * (_bottom - _top);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Image.asset(
            'assets/brand/bottle-premium.png',
            width: size,
            height: size,
            fit: BoxFit.contain,
          ),
          Positioned(
            left: bodyLeft,
            top: bodyTop,
            width: bodyWidth,
            height: bodyHeight,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(bodyWidth * 0.16),
              child: WaveFill(
                progress: progress,
                // Clear, light water with a whisper of depth — translucent so
                // the real bottle render shows through, never a solid blue.
                backColor: AppColors.waterLight.withValues(alpha: 0.30),
                frontColor: AppColors.waterMid.withValues(alpha: 0.38),
                // Slow, deliberate rise so the bottle visibly fills with water.
                levelDuration: const Duration(milliseconds: 2200),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

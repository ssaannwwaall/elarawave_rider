import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../theme/motion_config.dart';

/// The rising-water wipe: a solid marine rect rises from the bottom to
/// cover the screen, then recedes off the top to reveal the incoming page.
/// Registered on the Login and Home [GetPage]s (see app_pages.dart) so every
/// navigation to either — splash→login, splash→home, and logout (home→login)
/// — gets the same transition for free.
///
/// Falls back to a plain fade when [MotionConfig.reduceMotion] is set.
class WaterWipeTransition extends CustomTransition {
  @override
  Widget buildTransition(
    BuildContext context,
    Curve? curve,
    Alignment? alignment,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (!motion.motionEnabled) {
      return FadeTransition(opacity: animation, child: child);
    }
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, animatedChild) {
        const coverEnd = 0.55;
        final t = animation.value;
        final coverT = (t / coverEnd).clamp(0.0, 1.0);
        final recedeT = ((t - coverEnd) / (1 - coverEnd)).clamp(0.0, 1.0);
        final wipeHeightFactor = (t <= coverEnd ? coverT : (1 - recedeT)).clamp(0.0001, 1.0);
        final revealFactor = recedeT.clamp(0.0001, 1.0);

        return Stack(
          children: [
            ClipRect(
              child: Align(
                alignment: Alignment.topCenter,
                heightFactor: revealFactor,
                child: animatedChild,
              ),
            ),
            Positioned.fill(
              child: FractionallySizedBox(
                alignment: Alignment.bottomCenter,
                heightFactor: wipeHeightFactor,
                child: const ColoredBox(color: AppColors.marine),
              ),
            ),
          ],
        );
      },
    );
  }
}

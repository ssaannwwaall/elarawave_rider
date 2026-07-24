import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/motion_config.dart';

/// A droplet that falls, lands, ripples, and repeats. Replaces every
/// [CircularProgressIndicator] in the rider app (loading lists, refresh
/// indicator, etc). Falls back to a static droplet glyph when
/// [MotionConfig.reduceMotion] is set.
class WaterDropLoader extends StatefulWidget {
  final double size;
  final Color color;

  const WaterDropLoader({super.key, this.size = 40, this.color = AppColors.elaraBlue});

  @override
  State<WaterDropLoader> createState() => _WaterDropLoaderState();
}

class _WaterDropLoaderState extends State<WaterDropLoader> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Worker _motionWorker;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _syncMotion();
    _motionWorker = ever(motion.reduceMotion, (_) => _syncMotion());
  }

  void _syncMotion() {
    if (motion.motionEnabled) {
      _controller.repeat();
    } else {
      _controller
        ..stop()
        ..value = 0.7; // resting frame: droplet at rest near the surface
    }
  }

  @override
  void dispose() {
    _motionWorker.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          painter: _DropLoaderPainter(progress: _controller.value, color: widget.color),
        ),
      ),
    );
  }
}

class _DropLoaderPainter extends CustomPainter {
  final double progress;
  final Color color;

  _DropLoaderPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final fallPhase = (progress / 0.6).clamp(0.0, 1.0);
    final rippleT = progress <= 0.6 ? 0.0 : ((progress - 0.6) / 0.4).clamp(0.0, 1.0);

    final restY = size.height * 0.78;
    final startY = size.height * 0.05;
    final dropY = startY + (restY - startY) * Curves.easeIn.transform(fallPhase);
    final center = Offset(size.width / 2, size.height / 2);

    if (rippleT < 1.0) {
      final dropCenter = Offset(size.width / 2, dropY);
      final r = size.width * 0.09;
      final squash = 1.0 - (rippleT > 0 ? rippleT * 0.6 : 0.0);
      final path = Path()
        ..moveTo(dropCenter.dx, dropCenter.dy - r * 1.4)
        ..quadraticBezierTo(
          dropCenter.dx + r * squash,
          dropCenter.dy,
          dropCenter.dx,
          dropCenter.dy + r * squash,
        )
        ..quadraticBezierTo(
          dropCenter.dx - r * squash,
          dropCenter.dy,
          dropCenter.dx,
          dropCenter.dy - r * 1.4,
        )
        ..close();
      canvas.drawPath(path, Paint()..color = color);
    }

    if (rippleT > 0.0) {
      for (final ringT in [rippleT, (rippleT - 0.3).clamp(0.0, 1.0)]) {
        if (ringT <= 0) continue;
        final ringRadius = size.width * 0.12 + ringT * size.width * 0.28;
        final ringOpacity = (1 - ringT) * 0.6;
        canvas.drawOval(
          Rect.fromCenter(center: Offset(center.dx, restY), width: ringRadius * 2, height: ringRadius * 0.5),
          Paint()
            ..color = color.withValues(alpha: ringOpacity)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.6,
        );
      }
    }

    // Still-water line under everything.
    canvas.drawLine(
      Offset(size.width * 0.08, restY),
      Offset(size.width * 0.92, restY),
      Paint()
        ..color = color.withValues(alpha: 0.18)
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant _DropLoaderPainter oldDelegate) => oldDelegate.progress != progress;
}

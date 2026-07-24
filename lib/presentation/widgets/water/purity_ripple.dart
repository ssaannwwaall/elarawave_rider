import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/motion_config.dart';

/// A single expanding, fading ring — like a droplet landing on still water —
/// triggered on meaningful taps (login submit, day-tab change, pull-to-
/// refresh completion). One ring, 600ms, ease-out. Deliberately restrained:
/// this is what makes the feedback feel expensive rather than gimmicky.
///
/// No-op when [MotionConfig.reduceMotion] is set.
class PurityRipple {
  PurityRipple._();

  static void showAt(BuildContext context, Offset globalPosition, {Color color = AppColors.aqua}) {
    if (!motion.motionEnabled) return;

    final overlay = Overlay.of(context, rootOverlay: true);
    final overlayBox = overlay.context.findRenderObject() as RenderBox?;
    final localPosition = overlayBox?.globalToLocal(globalPosition) ?? globalPosition;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _RippleOverlay(
        position: localPosition,
        color: color,
        onCompleted: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }

  /// Convenience for showing the ripple centered on a tapped widget, given
  /// its [BuildContext].
  static void showAtWidget(BuildContext context, {Color color = AppColors.aqua}) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final center = box.localToGlobal(box.size.center(Offset.zero));
    showAt(context, center, color: color);
  }
}

class _RippleOverlay extends StatefulWidget {
  final Offset position;
  final Color color;
  final VoidCallback onCompleted;

  const _RippleOverlay({required this.position, required this.color, required this.onCompleted});

  @override
  State<_RippleOverlay> createState() => _RippleOverlayState();
}

class _RippleOverlayState extends State<_RippleOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))
      ..forward().whenComplete(widget.onCompleted);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = Curves.easeOut.transform(_controller.value);
          return CustomPaint(
            size: Size.infinite,
            painter: _RingPainter(center: widget.position, t: t, color: widget.color),
          );
        },
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final Offset center;
  final double t;
  final Color color;

  _RingPainter({required this.center, required this.t, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final radius = 4 + t * 46;
    final opacity = (1 - t) * 0.55;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color.withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) => oldDelegate.t != t;
}

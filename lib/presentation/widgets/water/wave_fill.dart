import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/motion_config.dart';

/// Two superimposed sine waves filling a container from the bottom up to
/// [progress] (0.0-1.0) — a lighter translucent wave behind a more opaque
/// one. Pure [CustomPainter], no dependencies. Used for the splash bottle
/// fill, the login button's loading sweep, and any future progress
/// indicator.
///
/// Wrap with a [ClipPath]/[clipper] to mask into a non-rectangular shape
/// (e.g. a bottle silhouette); omit it for a plain rounded-rect fill.
class WaveFill extends StatefulWidget {
  final double progress;
  final Color backColor;
  final Color frontColor;
  final CustomClipper<Path>? clipper;
  final BorderRadius borderRadius;

  /// How long the water level takes to ease to a new [progress]. Bumped up
  /// on the splash bottle so the fill rises slowly and reads as real water.
  final Duration levelDuration;

  const WaveFill({
    super.key,
    required this.progress,
    required this.backColor,
    required this.frontColor,
    this.clipper,
    this.borderRadius = BorderRadius.zero,
    this.levelDuration = const Duration(milliseconds: 900),
  });

  @override
  State<WaveFill> createState() => _WaveFillState();
}

class _WaveFillState extends State<WaveFill> with TickerProviderStateMixin {
  late final AnimationController _phaseController;
  late final AnimationController _levelController;
  late final Worker _motionWorker;

  @override
  void initState() {
    super.initState();
    _phaseController = AnimationController(vsync: this, duration: const Duration(seconds: 4));
    _levelController = AnimationController(
      vsync: this,
      duration: widget.levelDuration,
      value: widget.progress,
    );
    _syncMotion();
    // React live to MotionConfig — not just at creation — so toggling
    // "reduce motion" affects widgets already on screen.
    _motionWorker = ever(motion.reduceMotion, (_) => _syncMotion());
  }

  void _syncMotion() {
    if (motion.motionEnabled) {
      _phaseController.repeat();
    } else {
      _phaseController.stop();
    }
  }

  @override
  void didUpdateWidget(covariant WaveFill oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _levelController.animateTo(
        widget.progress,
        duration: widget.levelDuration,
        curve: Curves.easeOutCubic,
      );
    }
    _syncMotion();
  }

  @override
  void dispose() {
    _motionWorker.dispose();
    _phaseController.dispose();
    _levelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget painter = AnimatedBuilder(
      animation: Listenable.merge([_phaseController, _levelController]),
      builder: (context, _) {
        return CustomPaint(
          painter: _WaveFillPainter(
            phase: motion.motionEnabled ? _phaseController.value * 2 * pi : 0,
            level: _levelController.value,
            backColor: widget.backColor,
            frontColor: widget.frontColor,
          ),
          child: const SizedBox.expand(),
        );
      },
    );

    if (widget.clipper != null) {
      painter = ClipPath(clipper: widget.clipper, child: painter);
    } else if (widget.borderRadius != BorderRadius.zero) {
      painter = ClipRRect(borderRadius: widget.borderRadius, child: painter);
    }
    return painter;
  }
}

class _WaveFillPainter extends CustomPainter {
  final double phase;
  final double level;
  final Color backColor;
  final Color frontColor;

  _WaveFillPainter({
    required this.phase,
    required this.level,
    required this.backColor,
    required this.frontColor,
  });

  void _drawWave(
    Canvas canvas,
    Size size, {
    required double amplitude,
    required double frequency,
    required double phaseOffset,
    required double phaseSpeed,
    required Color color,
  }) {
    final baseline = size.height * (1 - level);
    final path = Path()..moveTo(0, size.height);
    for (double x = 0; x <= size.width; x += 2) {
      final y = baseline +
          sin((x / size.width * frequency * 2 * pi) + phase * phaseSpeed + phaseOffset) * amplitude;
      path.lineTo(x, y);
    }
    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (level <= 0.001) return;
    final amplitude = (size.height * 0.03).clamp(2.0, 10.0);

    _drawWave(
      canvas,
      size,
      amplitude: amplitude,
      frequency: 1.4,
      phaseOffset: pi / 3,
      phaseSpeed: 0.8,
      color: backColor,
    );
    _drawWave(
      canvas,
      size,
      amplitude: amplitude * 0.7,
      frequency: 2.0,
      phaseOffset: 0,
      phaseSpeed: 1.15,
      color: frontColor,
    );
  }

  @override
  bool shouldRepaint(covariant _WaveFillPainter oldDelegate) {
    return oldDelegate.phase != phase || oldDelegate.level != level;
  }
}
